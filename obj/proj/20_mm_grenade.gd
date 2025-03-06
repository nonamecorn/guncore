extends BasicProjectile


func on_collision(_collider):
	if !active: return
	active = false
	velocity = Vector2.ZERO
	for body in $HurtArea2D.get_overlapping_bodies():
		if body.has_method("hurt"):
			var dmg_coef = falloff.sample($Timer.time_left / $Timer.wait_time)
			body.hurt(damage)
	$AudioStreamPlayer2D.play()
	$AnimatedSprite2D.show()
	$AnimatedSprite2D.play()
	$light.show()
	$Sprite2D.hide()




func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
