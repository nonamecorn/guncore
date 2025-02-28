extends Sprite2D


@export var FOLLOW_SPEED = 16.0

func _physics_process(delta):
	var mouse_pos = get_global_mouse_position()
	global_position = global_position.lerp(mouse_pos, delta * FOLLOW_SPEED)

func apply_recoil(recoil_vector):
	var los_vec = global_position - get_parent().global_position
	print(los_vec)
	var new_len = los_vec.length() + recoil_vector.x
	var change_vec = los_vec - (los_vec.normalized() * new_len).rotated(deg_to_rad(recoil_vector.y * 0))
	global_position -= change_vec
