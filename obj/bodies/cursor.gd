extends Sprite2D


@export var FOLLOW_SPEED = 16.0

func _physics_process(delta):
	var mouse_pos = get_global_mouse_position()
	global_position = global_position.lerp(mouse_pos, delta * FOLLOW_SPEED)

func apply_recoil(recoil_vector):
	position += recoil_vector
