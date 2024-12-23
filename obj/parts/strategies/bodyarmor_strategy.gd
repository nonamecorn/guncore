extends BasicPlayerStrategy
class_name BodyArmorStrategy

@export var damage_absorbtion : float = 10.0

func init_strategy(_player):
	pass

func move_strategy(_player):
	pass

func hurt_strategy(player, damage : float, ap):
	if ap:
		player.health -= damage
	else:
		var ddtn = damage_absorbtion * (damage / 100)
		player.health -= (damage - ddtn)
