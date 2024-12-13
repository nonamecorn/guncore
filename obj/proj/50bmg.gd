extends BasicProjectile

func _on_area_2d_body_entered(body):
	if body.has_method("hurt"):
		body.hurt(damage, ap)
