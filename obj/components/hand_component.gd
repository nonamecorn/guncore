extends Node2D

@export var hand_length = 34

func _ready() -> void:
	$Marker2D.position.x = hand_length

var flipped = false

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_left_mouse"):
		$Marker2D.get_child(0).start_fire()
	if Input.is_action_just_released("ui_left_mouse"):
		$Marker2D.get_child(0).stop_fire()
	if Input.is_action_just_released("reload"):
		$Marker2D.get_child(0).reload()
	var look_vec = get_global_mouse_position() - global_position
	global_rotation = atan2(look_vec.y, look_vec.x)
	if look_vec.x < 0 and !flipped:
		flip()
	if look_vec.x >= 0 and flipped:
		flip()
	
func flip():
	get_parent().flip()
	flipped = !flipped
	scale.y *= -1

func add_gun(_gun):
	pass

func del_gun():
	pass

func switch_gun(gun):
	return gun
