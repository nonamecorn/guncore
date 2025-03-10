extends Enemy

var in_danger = false
var previous_state : int = IDLE
var look_vec

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
	$enemy_hand_component/Marker2D/gun_base.asseble_gun(unique_parts,true)

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
			direction = (get_self_circle_position(randomnum) - global_position).normalized() 
		SURROUND:
			pass
			#if !current_target or !is_instance_valid(current_target):
				#return
			#check_witness()
			#set_movement_target(get_circle_position(randomnum))
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
			pass
		INVESTIGATE:
			pass
			#direction = static_move_position
		RUN:
			run(delta)
		CHASE:
			pass

func alert(alert_position):
	if dead or state == SURROUND: return
	$enemy_hand_component.state = 1
	$change_position.wait_time = 2
	look_vec = alert_position - global_position
	#set_movement_target(static_move_position)
	$AlertTimer.start()
	previous_state = INVESTIGATE
	state = INVESTIGATE

func start_blastin(target):
	in_danger = true
	#print("ses")
	current_target = target
	$Sprite2D/idle.hide()
	#$Sprite2D/walk.show()
	$enemy_hand_component.state = 0
	#state = IDLE

func start_chasin():
	in_danger = false
	#if (current_target in $cqb_awarness.get_overlapping_bodies()) and state == SURROUND:
		#return
	GlobalVars.erase_witness(id)
	$Sprite2D/idle.hide()
	#$Sprite2D/walk.show()
	$enemy_hand_component.state = 1
	state = previous_state

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
		$enemy_hand_component.state = 1

func _on_alert_timer_timeout() -> void:
	if !in_danger:
		$change_position.wait_time = 2
		$enemy_hand_component.state = 1
		$AlertTimer.stop()
		previous_state = IDLE
		state = IDLE
