extends CharacterBody2D
class_name Enemy

const MAX_SPEED = 110
const ACCELERATION = 700
const FRICTION = 700

@onready var item_base = load("res://obj/components/item_ground_base.tscn")

var randomnum
var nearby_allies = []
var nearby_enemies = []
var current_target = null
var dead = false
enum {
	SURROUND,
	IDLE,
	RUN,
	IVESTIGATE
}
@export var armor = 0
@export var health = 50
var state = IDLE
var rng = RandomNumberGenerator.new()
var direction = Vector2.ZERO
var move_position

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
	
#	print(movement_target)
	rng.randomize()
	randomnum = rng.randf()
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

func _physics_process(delta):
	if dead: return
	if !current_target or !is_instance_valid(current_target):
		$enemy_hand_component.state = 1
		return
	
	match state:
		IDLE:
			direction = (get_self_circle_position(randomnum) - global_position).normalized() 
		SURROUND:
			surround(delta)
		IVESTIGATE:
			move(delta)
		RUN:
			run(delta)
func start_blastin():
	$makepath.start()
	set_movement_target(current_target.global_position)
	state = SURROUND

func start_chasin():
	set_movement_target(current_target.global_position)
	state = IVESTIGATE

func surround(delta):
	if nav_agent.is_navigation_finished():
		return
	get_circle_position(randomnum)
	var current_pos = global_position
	var next_path = nav_agent.get_next_path_position()
	var new_velocity = (next_path - current_pos).normalized()
	velocity = velocity.move_toward(new_velocity * MAX_SPEED,delta * ACCELERATION)
	move_and_slide()

func get_circle_position(random):
	var kill_circle_centre = current_target.global_position
	var radius = 200
#	Distance from center to circumference of circle
	var angle = random * PI * 2;
	var x = kill_circle_centre.x + cos(angle) * radius;
	var y = kill_circle_centre.y + sin(angle) * radius;
	set_movement_target(Vector2(x,y))

func run(delta):
	direction = (get_self_circle_position(randomnum) - global_position).normalized() 
	velocity = velocity.move_toward(direction * MAX_SPEED,delta * ACCELERATION)
	move_and_slide()

func get_self_circle_position(random):
	var kill_circle_centre = global_position
	var radius = 20
#	Distance from center to circumference of circle
	var angle = random * PI * 2;
	var x = kill_circle_centre.x + cos(angle) * radius;
	var y = kill_circle_centre.y + sin(angle) * radius;
	return(Vector2(x,y))

func move(delta):
	if nav_agent.is_navigation_finished():
		return
	var current_pos = global_position
	var next_path = nav_agent.get_next_path_position()
	var new_velocity = (next_path - current_pos).normalized()
	direction = new_velocity
	velocity = velocity.move_toward(new_velocity * MAX_SPEED,delta * ACCELERATION)
	move_and_slide()

func alert(alert_position):
	if dead: return
	state = IVESTIGATE
	$enemy_hand_component.state = 2
	$change_position.wait_time = 2
	set_movement_target(alert_position)

func _on_change_position_timeout():
	randomnum = rng.randf()

func _on_makepath_timeout():
	if dead or !is_instance_valid(current_target):
		return
	update_current_target()
	get_circle_position(randomnum)

func drop(item : Item):
	if dead: return
	var item_inst = item_base.instantiate()
	item_inst.global_position = global_position
	get_tree().current_scene.find_child("items").call_deferred("add_child",item_inst)
	item_inst.init(item)

func _on_body_manager_body_entered(_body: Node2D) -> void:
	update_current_target()

func _on_body_manager_body_exited(_body: Node2D) -> void:
	update_current_target()

func update_nearby_npcs():
	nearby_allies = []
	nearby_enemies = []
	for body in $body_manager.get_overlapping_bodies():
		if body.is_in_group(group):
			nearby_allies.append(body)
		else:
			nearby_enemies.append(body)

func update_current_target():
	update_nearby_npcs()
	current_target = get_closest(nearby_enemies)

func get_closest(array):
	var closest = null
	var smallest_distance = -1
	for body in array:
		var dist_to_body = global_position.distance_squared_to(body.global_position)
		if smallest_distance < 0 or dist_to_body < smallest_distance:
			closest = body
			smallest_distance = dist_to_body
	return closest


func hurt(amnt, ap):
	if !ap and armor != 0:
		return
	elif ap and armor != 0:
		var difference = armor - amnt
		if difference < 0:
			armor = 0
		else:
			armor = difference
	else:
		health -= amnt
		if health <= 0:
			call_deferred("die")
		if state == IDLE:
			state = RUN
			$change_position.wait_time = 0.5
			$enemy_hand_component.state = 2

func die():
	for part in unique_parts:
		if unique_parts[part]:
			drop(unique_parts[part])
	dead = true
	state = IDLE
	$death.play()
	$change_position.stop()
	$makepath.stop()
	$CollisionShape2D.disabled = true
	$enemy_hand_component.queue_free()
#	movement_target = null
	$Sprite2D.rotation_degrees = 90
	$Sprite2D.set_light_mask(1)
	$Sprite2D.set_visibility_layer(1)
	$Sprite2D.material = null
	print($Sprite2D.get_visibility_layer())
	
