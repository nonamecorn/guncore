extends Control

@export var checkbox : Node

func _ready() -> void:
	checkbox.button_pressed = GlobalVars.fullscreen

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if !visible and get_tree().paused:
			return
		get_tree().paused = !get_tree().paused
		visible = !visible

func toggle():
	if !visible and get_tree().paused:
		return
	get_tree().paused = !get_tree().paused
	visible = !visible

func _on_button_pressed():
	pass # Replace with function body.


func _on_fulcreen_toggled(toggled_on):
	if toggled_on:
		GlobalVars.fullscreen = true
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		GlobalVars.fullscreen = false
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		get_window().size = Vector2i(1280, 720)

	


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_retry_button_pressed() -> void:
	get_tree().paused = !get_tree().paused
	GlobalVars._ready()
	get_tree().call_deferred("change_scene_to_file","res://lvls/world_1.tscn")
