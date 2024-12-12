extends BasicBulletStrategy
class_name AutoAimStrategy


func init_strategy(bullet):
	var ray_obj = load("res://obj/components/autoaim_raycast.tscn")
	var ray = ray_obj.instantiate()
	bullet.add_child(ray)
	bullet.strategy_dic.target = null

func move_strategy(bullet : Node):
	if !bullet.strategy_dic.target:
		var ray : RayCast2D = bullet.get_child(bullet.get_children().size() - 1)
		ray.force_raycast_update()
		if ray.is_colliding() and ray.get_collider().is_in_group("targetable"):
			bullet.strategy_dic.target = ray.get_collider()
	else:
		var new_vec = (bullet.strategy_dic.target.global_position - bullet.global_position).normalized()
		bullet.move_vec = new_vec
