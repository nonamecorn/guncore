extends Node2D


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_left_mouse"):
		var tween = create_tween()
		tween.tween_property($ColorRect, "size", Vector2(500, 40), 1)
	if Input.is_action_just_released("ui_left_mouse"):
		var tween = create_tween()
		tween.tween_property($ColorRect, "size", Vector2(50, 40), 1)
