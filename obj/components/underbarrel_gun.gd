extends Node2D
class_name Underbarrel

@export var max_ammo : float
@export var ammo : float
@export var gpuparticles : Node
@export var spread : float
@export var added_velocity : float
@export var range : float
@export var add_spd : float
@export var num_of_boolets : int

@export var falloff : Curve
@onready var rng = RandomNumberGenerator.new()
@export var bullet_obj : PackedScene
@export var pitch_shifing : Curve

var player_crosshair

func _ready() -> void:
	player_crosshair = get_tree().get_nodes_in_group("crosshair")[0]
	rng.randomize()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_right_mouse"):
		fire()

func fire_faff():
	$AnimationPlayer.play("fire")
	$audio/shoting.pitch_scale = pitch_shifing.sample(ammo)
	$audio/shoting.play()

func fire():
	for i in num_of_boolets:
		if ammo <= 0:
			gpuparticles.emitting = false
			return
		ammo -= 1
		fire_faff()
		for body in $noise_alert.get_overlapping_bodies():
			if body.has_method("alert"):
				body.alert(global_position)
		
		var bullet_inst = bullet_obj.instantiate()
		bullet_inst.global_position = $pos.global_position
		bullet_inst.global_rotation_degrees = global_rotation_degrees + rng.randf_range(-spread, spread)
		added_velocity = get_parent().get_parent().get_parent().velocity/2
		bullet_inst.falloff = falloff
		bullet_inst.max_range = range
		append_strategies(bullet_inst)
		get_tree().current_scene.call_deferred("add_child",bullet_inst)
		bullet_inst.init(added_velocity, range, add_spd)
		var recoil_vector = Vector2.ZERO
		get_parent().get_parent().apply_recoil(recoil_vector)

func append_strategies(bullet_inst):
	pass
