extends BasicBulletStrategy

class_name MultDamageStrategy

@export var mult_damage: float = 0.0

func init_strategy(bullet):
	bullet.damage *= mult_damage
