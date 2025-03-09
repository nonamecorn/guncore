extends Sprite2D


@export var FOLLOW_SPEED = 100.0
@export var HANDLING_SPEED = 20.0
var firing = false
@export var weight_to_handle : Curve
@export var player_handled : bool
var look_pos = Vector2.ZERO
var current_target

func set_handling_spd(weight):
	HANDLING_SPEED = weight_to_handle.sample(weight)
	#print(HANDLING_SPEED)

func _physics_process(delta):
	if player_handled:
		look_pos = get_global_mouse_position()
	else:
		current_target = get_parent().current_target
		if !current_target: return
		look_pos = current_target.global_position + (current_target.velocity * delta)
	#if firing:
	global_position = global_position.lerp(look_pos, delta * HANDLING_SPEED)
	#else:
		#global_position = global_position.lerp(mouse_pos, delta * FOLLOW_SPEED)

func apply_recoil(recoil_vector):
	var los_vec = global_position - get_parent().global_position
	var new_len = los_vec.length() + recoil_vector.x
	var change_vec = los_vec - (los_vec.normalized() * new_len).rotated(deg_to_rad(recoil_vector.y))
	global_position -= change_vec
	firing = true
	$Timer.start()


func _on_timer_timeout() -> void:
	firing = false
