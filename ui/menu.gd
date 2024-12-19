extends Control


func _on_start_button_pressed() -> void:
	get_tree().paused = false
	OstManager.switch_track("Shop")
	get_tree().call_deferred("change_scene_to_file","res://lvls/world_1_shop.tscn")

func _on_options_button_pressed() -> void:
	$pause.toggle()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
