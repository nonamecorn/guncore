extends Enemy


func _ready():
	id = IdGiver.get_id()
#	print(movement_target)
	GlobalVars.people += 1
	rng.randomize()
	randomnum = rng.randf()
	$hurt_box.damaged.connect(hurt)
	parts = Randogunser.get_corp_gun()
	for part in parts:
		if parts[part]:
			unique_parts[part] = load(parts[part])
	#$enemy_hand_component/Marker2D.get_child(0).asseble_gun(unique_parts,true)

func gib():
	$Corp_head.emitting = true 
	$Corp_helmet.emitting = true 
	$Gore/Gore_emitter.emitting = true
