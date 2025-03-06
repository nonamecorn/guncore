extends Node2D

func explode(damage):
	$AudioStreamPlayer2D.play()
	$AnimatedSprite2D.show()
	$AnimatedSprite2D.play()
	$light.show()
	for body in $HurtArea2D.get_overlapping_bodies():
		if body.has_method("hurt"):
			body.hurt(damage)
