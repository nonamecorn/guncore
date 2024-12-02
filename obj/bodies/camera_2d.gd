extends Camera2D

var camera = Vector2.ZERO

var follow = true
func _physics_process(_delta):
	if !follow: return
	global_position = Vector2(
	(get_global_mouse_position().x + get_parent().global_position.x) / 2,
	 (get_global_mouse_position().y + get_parent().global_position.y) / 2)
