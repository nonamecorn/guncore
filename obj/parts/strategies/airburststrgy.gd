extends BasicShootingStratagy
class_name Airburst
var base_range

func apply_strategy(bullet : Node2D,gun : Node2D):
	if !base_range: base_range = gun.range
	var distance = (gun.get_global_mouse_position() - gun.get_point_of_fire()).length()
	var velocity = (Vector2.RIGHT * (bullet.speed + gun.add_spd)).rotated(bullet.global_rotation)
	gun.range = distance / velocity.length()
	if gun.range > base_range: gun.range = base_range
