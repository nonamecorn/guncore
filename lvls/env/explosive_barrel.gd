extends CharacterBody2D

@export var damage : int = 300
var exploded = false

func hurt(_amnt):
	if exploded: return
	exploded = true
	for body in $HurtArea2D.get_overlapping_bodies():
		if body.has_method("hurt"):
			body.hurt(damage)
	$AudioStreamPlayer2D.play()
	$AnimationPlayer.play("explode")
	$AnimatedSprite2D.show()
	$AnimatedSprite2D.play()
	$Sprite2D.hide()


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
