extends Control

func _on_rtry_button_pressed() -> void:
	GlobalVars.change_score(0,0)
	GlobalVars.items = []
	GlobalVars.fullscreen = false
	GlobalVars.money = 1000
	GlobalVars._ready()
	get_tree().call_deferred("change_scene_to_file","res://lvls/world_1_shop.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
