extends CharacterBody2D

@export var MAX_SPEED = 110
@export var  ACCELERATION = 700
@export var  FRICTION = 700
@export var HEALTH = 50
@export var group : String = "cultist"
@export var nav_agent: NavigationAgent2D
@export var angle_cone_of_vission = 30
@export var max_viev_distance = 600
@export var max_engage_distance = 300
@export var ray : Node 


@onready var item_base = load("res://obj/components/item_ground_base.tscn")

var nearby_allies = []
var nearby_enemies = []
var current_target = null
var move_position
var targets = []
var circle_arg
var dead = false
var input_vector = Vector2.ZERO


var rng = RandomNumberGenerator.new()
var flipped = false

var state = IDLE
var look_vec


enum {
	SURROUND,
	IDLE,
	RUN,
	INVESTIGATE,
	CHASE
}

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
	rng.randomize()
	circle_arg = rng.randf()
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
	if !current_target: return
	if state != IDLE:
		move(delta)
	match state:
		IDLE:
			idle()
		SURROUND:
			surround()
		INVESTIGATE:
			investigate()
		RUN:
			run()
		CHASE:
			chase()
	if state == INVESTIGATE or state == RUN:
		$enemy_hand_component.global_rotation = atan2(input_vector.y, input_vector.x)
	else:
		$enemy_hand_component.global_rotation = atan2(current_target.global_position.y,
		 current_target.global_position.x)

func idle():
	var look_vec = get_circle_position(circle_arg, global_position)
	$enemy_hand_component.global_rotation = atan2(look_vec.y, look_vec.x)
	if _in_vision_cone(current_target.global_position) and has_los(current_target):
		if global_position.distance_to(current_target.global_position) <= max_engage_distance:
			state = SURROUND
			$enemy_hand_component/attack.start()
		else:
			state = CHASE


func chase():
	if !_in_vision_cone(current_target.global_position) or !has_los(current_target):
		state = RUN

func surround():
	move_position = get_circle_position(circle_arg, current_target.global_position)
	if !_in_vision_cone(current_target.global_position) or !has_los(current_target):
		state = RUN

func run():
	move_position = get_circle_position(circle_arg, global_position)
	if _in_vision_cone(current_target.global_position) and has_los(current_target):
		if global_position.distance_to(current_target.global_position) <= max_engage_distance:
			state = SURROUND
			$enemy_hand_component/attack.start()
		else:
			state = CHASE

func investigate():
	if _in_vision_cone(current_target.global_position) and has_los(current_target):
		if global_position.distance_to(current_target.global_position) <= max_engage_distance:
			state = SURROUND
			$enemy_hand_component/attack.start()
		else:
			state = CHASE

func alert(alert_position):
	move_position = alert_position
	state = INVESTIGATE

func get_circle_position(random, center_pos : Vector2) -> Vector2:
	var kill_circle_centre = center_pos
	var radius = 200
#	Distance from center to circumference of circle
	var angle = random * PI * 2;
	var x = kill_circle_centre.x + cos(angle) * radius;
	var y = kill_circle_centre.y + sin(angle) * radius;
	return(Vector2(x,y))

func move(delta):
	if nav_agent.is_navigation_finished():
		return
	input_vector = find_desirable_dir(nav_agent.get_next_path_position())
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED,delta * ACCELERATION)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, delta * FRICTION)
	move_and_slide()


func find_desirable_dir(point) -> Vector2:
	var desireable_vec = point - global_position
	print(desireable_vec)
	var vecs = [
		Vector2.RIGHT, Vector2(1,1).normalized(), 
		Vector2.DOWN, Vector2(-1,1).normalized(), 
		Vector2.LEFT, Vector2(-1,-1).normalized(),
		Vector2.UP, Vector2(1,-1).normalized()
		]
	var new_coef = vecs.map(func(vect):  return vect.dot(desireable_vec.normalized()))
	var danger_coef : Array[float] = []
	for i in 7:
		danger_coef.append(0.0)
		var norm_ray : RayCast2D = $danger_detector.get_child(i)
		norm_ray.target_position = vecs[i] * 20
		norm_ray.force_raycast_update()
		if norm_ray.is_colliding():
			danger_coef[i] += 5
			if i - 1 < 0:
				danger_coef[danger_coef.size() - 1] = 3
			else: danger_coef[i - 1] += 3
			if i + 1 > danger_coef.size() - 1:
				danger_coef[0] += 3
			else: danger_coef[i + 1] = 3
	var max_index = null
	for i in 7:
		var ses = new_coef[i] - danger_coef[i]
		if !max_index or ses > max_index:
			max_index = ses
	return(vecs[max_index])

func drop(item : Item):
	var item_inst = item_base.instantiate()
	item_inst.global_position = global_position
	get_tree().current_scene.find_child("items").call_deferred("add_child",item_inst)
	item_inst.init(item)

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
	if current_target: $makepath.start()

func get_closest(array):
	var closest = null
	var smallest_distance = -1
	for body in array:
		var dist_to_body = global_position.distance_squared_to(body.global_position)
		if smallest_distance < 0 or dist_to_body < smallest_distance:
			closest = body
			smallest_distance = dist_to_body
	return closest

func _in_vision_cone(point):
	var forward = ($enemy_hand_component/Marker2D.global_position - global_position).normalized()
	var dir_to_point = point - global_position
	return abs(rad_to_deg(dir_to_point.angle_to(forward))) <= angle_cone_of_vission

func has_los(target : Node):
	ray.target_position = target.global_position - global_position
	ray.force_raycast_update()
	if ray.is_colliding() and ray.get_collider() == target:
		return true
	return false

func hurt(value):
	HEALTH -= value
	if HEALTH <= 0:
		call_deferred("die")
	if state == IDLE:
		state = RUN
		$change_circle_pos.wait_time = 0.5

func die():
	for part in unique_parts:
		if unique_parts[part]:
			drop(unique_parts[part])
	dead = true
	state = IDLE
	$death.play()
	$change_circle_pos.stop()
	$makepath.stop()
	$CollisionShape2D.disabled = true
	$enemy_hand_component.queue_free()
#	movement_target = null
	$Sprite2D.rotation_degrees = 90


func _on_body_manager_body_entered(body: Node2D) -> void:
	update_current_target()


func _on_body_manager_body_exited(body: Node2D) -> void:
	update_current_target()


func _on_makepath_timeout() -> void:
	match state:
		IDLE:
			$makepath.stop()
		SURROUND:
			set_movement_target(move_position)
		INVESTIGATE:
			set_movement_target(move_position)
		RUN:
			set_movement_target(move_position)
		CHASE:
			set_movement_target(current_target.global_position)


func _on_change_circle_pos_timeout() -> void:
	circle_arg = rng.randf()
