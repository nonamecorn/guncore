extends BasicProjectile


func on_collision(_collider):
	if !active: return
	active = false
	velocity = Vector2.ZERO
	$Sprite2D.hide()
	$explosion.explode(damage)




func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
