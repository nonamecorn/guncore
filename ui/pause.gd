extends Control

func _ready() -> void:
	$NinePatchRect/CheckBox.button_pressed = GlobalVars.fullscreen

func _input(event):
	if event.is_action_pressed("ui_cancel"):
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

	
