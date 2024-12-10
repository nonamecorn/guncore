extends Enemy


func _ready():
#	print(movement_target)
	rng.randomize()
	randomnum = rng.randf()
	parts = Randogunser.get_corp_gun()
	for part in parts:
		if parts[part]:
			unique_parts[part] = load(parts[part])
	$enemy_hand_component/Marker2D/gun_base.asseble_gun(unique_parts)
