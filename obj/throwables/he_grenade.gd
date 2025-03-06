extends RigidBody2D

@export var damage : float = 250.0

func _on_timer_timeout() -> void:
	$explosion.explode(damage)
	$Sprite2D.hide()


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
