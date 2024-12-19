extends Node2D

@export var active = false

func _physics_process(_delta: float) -> void:
	if !active : return
	global_position = get_global_mouse_position()
