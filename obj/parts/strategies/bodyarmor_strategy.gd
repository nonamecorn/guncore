extends BasicPlayerStrategy
class_name BodyArmorStrategy

@export var damage_absorbtion : int = 10

func init_strategy(player):
	pass

func move_strategy(player):
	pass

func hurt_strategy(player, damage, ap):
	if ap:
		player.hp -= damage
	else:
		var ddtn = damage_absorbtion * (damage / 100)
		player.hp -= (damage - ddtn)
