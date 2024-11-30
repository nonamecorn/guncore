extends Node2D

var bullet_obj = preload("res://obj/proj/fmj.tscn")
var point_of_shooting = Vector2(0,0)
@export var base_range = 0.0
@export var base_max_ammo = 0
@export var base_spread = 0.0

var current_max_ammo = base_max_ammo
var current_ammo = base_max_ammo
var current_spread = base_spread
var current_range = base_range
var num_of_bullets = 1
@export var recoil = 10
@export var number_of_mods = 0
@export var player_handled = false

signal empty

@onready var rng = RandomNumberGenerator.new()
func _ready() -> void:
	rng.randomize()

func update():
	pass

func start_fire():
	fire()
	$firerate.start()

func stop_fire():
	$firerate.stop()

func reload():
	current_ammo = base_max_ammo

func fire():
	if current_ammo > 0:
		for i in num_of_bullets:
			current_ammo -= 1
			if  player_handled:
				Input.warp_mouse(get_viewport().get_mouse_position() + Vector2(recoil,0).rotated(global_rotation))
			var bullet_inst = bullet_obj.instantiate()
			bullet_inst.global_position = $mods_markers.check_point_of_fire()
			bullet_inst.global_rotation_degrees = global_rotation_degrees + rng.randf_range(-base_spread, base_spread)
			get_tree().current_scene.add_child(bullet_inst)
			bullet_inst.init(get_parent().get_parent().get_parent().velocity, base_range)
		return
	empty.emit()
