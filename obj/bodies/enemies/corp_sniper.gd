extends Enemy

var in_danger = false
var look_vec

func _ready():
	id = IdGiver.get_id()
#	print(movement_target)
	GlobalVars.people += 1
	rng.randomize()
	randomnum = rng.randf()
	$hurt_box.damaged.connect(hurt)
	parts = Randogunser.get_scout_kit()
	for part in parts:
		if parts[part]:
			unique_parts[part] = load(parts[part])
	$enemy_hand_component/Marker2D.get_child(0).asseble_gun(unique_parts,true)

func gib():
	$Corp_head.emitting = true 
	$Corp_helmet.emitting = true 
	$Gore/Gore_emitter.emitting = true
func _on_less_crucial_checks_timeout() -> void:
	if  dead:
		return
	$Label.text = str(state, $enemy_hand_component.state)
	match state:
		IDLE:
			#check_witness()
			direction = (get_self_circle_position(randomnum) - global_position).normalized() 
		SURROUND:
			if !current_target or !is_instance_valid(current_target):
				return
			#check_witness()
			set_movement_target(get_circle_position(randomnum))
		INVESTIGATE:
			direction = look_vec
			#set_movement_target(static_move_position)
		RUN:
			pass
			#if $wall_detector.get_overlapping_bodies().size() != 0:
				#_on_change_position_timeout()
			#set_movement_target(get_self_circle_position(randomnum))
		CHASE:
			pass
			#check_witness()
			#set_movement_target(current_target.global_position)
func _physics_process(delta):
	if dead: return
	match state:
		IDLE:
			pass
		SURROUND:
			surround(delta)
			static_move_position = current_target.global_position
		INVESTIGATE:
			pass
			#direction = static_move_position
		RUN:
			run(delta)
		CHASE:
			pass

func alert(alert_position):
	if dead or state == SURROUND: return
	#print("alert")
	look_vec = alert_position - global_position
	#print(look_vec)
	if look_vec.length() <= 30.0:
		return
	$enemy_hand_component.switch_to_idle()
	$change_position.wait_time = 2
	#set_movement_target(static_move_position)
	$AlertTimer.start()
	state = INVESTIGATE

func start_blastin(target):
	in_danger = true
	#print("ses")
	current_target = target
	#$Sprite2D/idle.hide()
	#$Sprite2D/walk.show()
	$enemy_hand_component.switch_to_fire()
	#state = IDLE

func start_chasin():
	in_danger = false
	#if (current_target in $cqb_awarness.get_overlapping_bodies()) and state == SURROUND:
		#return
	GlobalVars.erase_witness(id)
	#$Sprite2D/idle.hide()
	#$Sprite2D/walk.show()
	$enemy_hand_component.switch_to_idle()
	if state == SURROUND:
		state = RUN

func hurt(amnt):
	if dead: return
	health -= amnt
	emitte()
	if health <= 0:
		call_deferred("die")
	if !in_danger or health <= 50.0:
		state = RUN
		$AlertTimer.start()
		$change_position.wait_time = 0.5
		$enemy_hand_component.switch_to_idle()

func _on_alert_timer_timeout() -> void:
	if !in_danger:
		$Sprite2D/idle.show()
		$Sprite2D/walk.hide()
		$change_position.wait_time = 2
		$enemy_hand_component.switch_to_idle()
		$AlertTimer.stop()
		state = IDLE


func _on_cqb_awareness_body_entered(body: Node2D) -> void:
	if body.is_in_group(group) or !body.has_method("hurt"): return
	#print(group)
	in_danger = true
	current_target = body
	$Sprite2D/idle.hide()
	$Sprite2D/walk.show()
	$enemy_hand_component.switch_to_fire()
	$AlertTimer.start()
	state = SURROUND
	#state = IDLE

func die():
	if dead: return
	var invent = []
	for part in unique_parts:
		if unique_parts[part]:
			invent.append(unique_parts[part])
	invent.shuffle()
	drop(invent[0])
	dead = true
	state = IDLE
	current_target = null
	
	$death.play()
	$less_crucial_checks.stop()
	$CollisionShape2D.disabled = true
	$hurt_box/CollisionShape2D.disabled = true
	$enemy_hand_component.queue_free()
	$AlertTimer.stop()
#	movement_target = null
	if health <= -30.0:
		$Sprite2D.hide()
		gib()
	$Sprite2D.rotation_degrees = 90
	$Sprite2D/idle.set_light_mask(1)
	$Sprite2D/idle.set_visibility_layer(1)
	$Sprite2D/idle.material = null
	$Sprite2D/idle.show()
	$Sprite2D/idle.stop()
	$Sprite2D/walk.hide()
	GlobalVars.erase_witness(id)
	GlobalVars.change_score(GlobalVars.kills + 1, GlobalVars.loop)
