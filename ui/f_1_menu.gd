extends Control

func _input(event):
	if event.is_action_pressed("ui_help"):
		if !visible and get_tree().paused:
			return
		get_tree().paused = !get_tree().paused
		visible = !visible
	#if event.is_action_pressed("ui_cancel") and visible:
		#if !visible and get_tree().paused:
			#return
		#get_tree().paused = !get_tree().paused
		#visible = !visible
