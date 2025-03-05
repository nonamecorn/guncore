extends BasicProjectile

func _on_area_2d_body_entered(body):
	if body.has_method("hurt"):
		var dmg_coef = falloff.sample($Timer.time_left / $Timer.wait_time)
		body.hurt(damage * dmg_coef)
