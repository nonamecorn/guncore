extends Area2D

#af

func _on_body_entered(_body: Node2D) -> void:
	OstManager.switch_track("Battle_metal")
