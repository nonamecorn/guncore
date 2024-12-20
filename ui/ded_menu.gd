extends Control

func _on_rtry_button_pressed() -> void:
	GlobalVars._ready()
	get_tree().call_deferred("change_scene_to_file","res://lvls/world_1.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
