extends Node2D

signal fire

func _physics_process(_delta):
	if Input.is_action_just_pressed("ui_left_mouse"):
		fire.emit()
