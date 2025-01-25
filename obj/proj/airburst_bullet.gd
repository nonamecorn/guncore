extends BasicProjectile

var current_bullet_obj = preload("res://obj/proj/PP_fmj.tscn")

func on_collision(collider):
	if collider and collider.get_collider().has_method("hurt"):
		collider.get_collider().hurt(damage)
	active = false
	$Sprite2D.hide()
	create_spark()
	queue_free()
	
	for i in 3:
		var bullet_inst = current_bullet_obj.instantiate()
		bullet_inst.global_position = global_position
		bullet_inst.global_rotation_degrees = global_rotation_degrees + rng.randf_range(-22, 22)
		var added_velocity = Vector2.ZERO
		get_tree().current_scene.call_deferred("add_child",bullet_inst)
		bullet_inst.init(added_velocity, 0.5, 0)
