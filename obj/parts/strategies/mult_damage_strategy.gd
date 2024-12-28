extends BasicBulletStrategy

class_name MultDamageStrategy

@export var mult_damage: int = 0

func init_strategy(bullet):
	bullet.damage *= mult_damage
