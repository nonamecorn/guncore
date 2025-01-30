extends CharacterBody2D
class_name Enemy

const MAX_SPEED = 110
const ACCELERATION = 700
const FRICTION = 700

@onready var item_base = load("res://obj/components/item_ground_base.tscn")

var randomnum

var current_target = null
var dead = false
var id : int

enum {
	SURROUND,
	IDLE,
	RUN,
	INVESTIGATE,
	CHASE
}
@export var armor = 0
@export var health = 50
var state = IDLE
var rng = RandomNumberGenerator.new()
var direction = Vector2.ZERO
var static_move_position = null

@export var group : String
@export var nav_agent: NavigationAgent2D
var flipped = false

var parts = {}
var unique_parts = {
		"RECIEVER": null,
		"BARREL": null,
		"MAG": null,
		"MUZZLE": null,
		"GUTS": null,
		"ATTACH": null,
	}
func _ready():
	id = IdGiver.get_id()
	GlobalVars.people += 1
#	print(movement_target)
	rng.randomize()
	randomnum = rng.randf()
	$hurt_box.damaged.connect(hurt)
	parts = Randogunser.get_gun()
	for part in parts:
		if parts[part]:
			unique_parts[part] = load(parts[part])
	$enemy_hand_component/Marker2D/gun_base.asseble_gun(unique_parts)

func flip():
	flipped = !flipped
	$Sprite2D.scale.x *= -1

func set_movement_target(target_point: Vector2):
	nav_agent.target_position = target_point

func _on_less_crucial_checks_timeout() -> void:
	if  dead:
		return
	$Label.text = str(state)
	
	match state:
		IDLE:
			direction = (get_self_circle_position(randomnum) - global_position).normalized() 
		SURROUND:
			if !current_target or !is_instance_valid(current_target):
				return
			check_witness()
			set_movement_target(get_circle_position(randomnum))
		INVESTIGATE:
			set_movement_target(static_move_position)
		RUN:
			pass
			set_movement_target(get_self_circle_position(randomnum))
		CHASE:
			check_witness()
			set_movement_target(current_target.global_position)


func _physics_process(delta):
	if dead: return
	match state:
		IDLE:
			direction = (get_self_circle_position(randomnum) - global_position).normalized() 
		SURROUND:
			surround(delta)
			static_move_position = current_target.global_position
		INVESTIGATE:
			move(delta)
		RUN:
			run(delta)
		CHASE:
			move(delta)
func start_blastin(target):
	print("ses")
	current_target = target
	$Sprite2D/idle.hide()
	$Sprite2D/walk.show()
	$enemy_hand_component.state = 0
	state = SURROUND

func start_chasin():
	#if (current_target in $cqb_awarness.get_overlapping_bodies()) and state == SURROUND:
		#return
	$Sprite2D/idle.hide()
	$Sprite2D/walk.show()
	$enemy_hand_component.state = 1
	state = INVESTIGATE

func surround(delta):
	if nav_agent.is_navigation_finished():
		return
	if !current_target:
		$enemy_hand_component.state = 1
		print("wesdw")
		state = INVESTIGATE
	$enemy_hand_component.state = 0
	var current_pos = global_position
	var next_path = nav_agent.get_next_path_position()
	var new_velocity = (next_path - current_pos).normalized()
	velocity = velocity.move_toward(new_velocity * MAX_SPEED,delta * ACCELERATION)
	move_and_slide()

func run(delta):
	direction = (get_self_circle_position(randomnum) - global_position).normalized() 
	velocity = velocity.move_toward(direction * MAX_SPEED,delta * ACCELERATION)
	move_and_slide()

func move(delta):
	if nav_agent.is_navigation_finished():
		$enemy_hand_component.state = 1
		state = RUN
		return
	var current_pos = global_position
	var next_path = nav_agent.get_next_path_position()
	var new_velocity = (next_path - current_pos).normalized()
	direction = new_velocity
	velocity = velocity.move_toward(new_velocity * MAX_SPEED,delta * ACCELERATION)
	move_and_slide()


func get_circle_position(random) -> Vector2:
	var kill_circle_centre = current_target.global_position
	var radius = 200
#	Distance from center to circumference of circle
	var angle = random * PI * 2;
	var x = kill_circle_centre.x + cos(angle) * radius;
	var y = kill_circle_centre.y + sin(angle) * radius;
	return(Vector2(x,y))

func get_self_circle_position(random) -> Vector2:
	var kill_circle_centre = global_position
	var radius = 20
#	Distance from center to circumference of circle
	var angle = random * PI * 2;
	var x = kill_circle_centre.x + cos(angle) * radius;
	var y = kill_circle_centre.y + sin(angle) * radius;
	return(Vector2(x,y))


func alert(alert_position):
	if dead or state == SURROUND: return
	$enemy_hand_component.state = 1
	$change_position.wait_time = 2
	static_move_position = alert_position
	set_movement_target(static_move_position)
	state = INVESTIGATE

func _on_change_position_timeout():
	randomnum = rng.randf()

func drop(item : Item):
	if dead: return
	var item_inst = item_base.instantiate()
	item_inst.global_position = global_position
	get_tree().current_scene.find_child("items").call_deferred("add_child",item_inst)
	item_inst.init(item)

func check_witness():
	if current_target.is_in_group("player"):
		GlobalVars.add_witness(id)
	else:
		GlobalVars.erase_witness(id)



func hurt(amnt):
	if dead: return
	health -= amnt
	if health <= 0:
		call_deferred("die")
	if state == IDLE:
		state = RUN
		$change_position.wait_time = 0.5
		$enemy_hand_component.state = 2

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
#	movement_target = null
	$Sprite2D.rotation_degrees = 90
	$Sprite2D/idle.set_light_mask(1)
	$Sprite2D/idle.set_visibility_layer(1)
	$Sprite2D/idle.material = null
	$Sprite2D/idle.show()
	$Sprite2D/idle.stop()
	$Sprite2D/walk.hide()
	GlobalVars.erase_witness(id)
	GlobalVars.change_score(GlobalVars.kills + 1, GlobalVars.loop)
