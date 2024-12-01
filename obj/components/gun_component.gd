extends Node2D

var bullet_obj = preload("res://obj/proj/fmj.tscn")
var point_of_shooting = Vector2(0,0)
@export var base_range = 0.0
@export var base_max_ammo = 0
@export var base_spread = 0.0

var current_max_ammo
var current_ammo
var current_spread
var current_range

@export var num_of_bullets = 10
@export var ver_recoil = 10
@export var hor_recoil = 10
@export var number_of_mods = 0
@export var player_handled = false

var tween

signal empty

@onready var rng = RandomNumberGenerator.new()
func _ready() -> void:
	current_max_ammo = base_max_ammo
	current_ammo = base_max_ammo
	current_spread = 0
	current_range = base_range
	rng.randomize()

func update():
	pass

func start_fire():
	if current_ammo <= 0: return
	fire()
	if tween: tween.kill()
	tween = create_tween()
	tween.tween_property(self, "current_spread", base_spread, 3)
	$firerate.start()

func stop_fire():
	tween.kill()
	tween = create_tween()
	tween.tween_property(self, "current_spread", 0, 1)
	$firerate.stop()
#
func reload():
	current_spread = 0
	current_ammo = base_max_ammo
func fire():
	for i in num_of_bullets:
		if current_ammo > 0:
			current_ammo -= 1
			if  player_handled:
				var vievscale = get_viewport_transform().get_scale()
				Input.warp_mouse(get_viewport().get_mouse_position()*vievscale + Vector2(-ver_recoil,randf_range(-hor_recoil, hor_recoil)).rotated(global_rotation)*vievscale)
			var bullet_inst = bullet_obj.instantiate()
			bullet_inst.global_position = $mods_markers.check_point_of_fire()
			bullet_inst.global_rotation_degrees = global_rotation_degrees + rng.randf_range(-current_spread, current_spread)
			get_tree().current_scene.call_deferred("add_child",bullet_inst) 
			bullet_inst.init(get_parent().get_parent().get_parent().velocity, base_range)
		else: empty.emit()
	
