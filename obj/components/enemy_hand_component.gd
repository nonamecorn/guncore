extends Node2D

@export var hand_length = 80
var state = IDLE
var look_vec = Vector2.ZERO
var angle_cone_of_vission = 55
var angle_between_rays = 10
var max_viev_distance = 600
var current_target

var bodies = []
var nearby_allies = []
var nearby_enemies = []
var group : String

@export var ray : Node
@export var particles : Node 
@export var turn_speed = 200.0
enum {
	FIRING,
	IDLE,
}

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	group = get_parent().group
	rng.randomize()
	$Marker2D.position.x = hand_length
	$Marker2D.get_child(0).empty.connect(reload)

var flipped = false


func face_point(delta: float):
	var direction = look_vec
	var angle = transform.x.angle_to(direction)
	rotate(sign(angle) * min(delta*deg_to_rad(turn_speed), abs(angle)))

func is_facing_target(target_point: Vector2):
	var l_target_pos = to_local(target_point)
	return l_target_pos.z < 0 and abs(l_target_pos.x) < 1.0

func _physics_process(delta: float) -> void:
	current_target = get_parent().current_target
	match state:
		IDLE:
			idle_state()
		FIRING:
			firing_state()
	if look_vec.x < 0 and !flipped:
		flip()
	if look_vec.x >= 0 and flipped:
		flip()
	face_point(delta)
	
	if rng.randi_range(0,1) == 1:
		bodies = get_tree().get_nodes_in_group("body")
		update_current_target()

func firing_state():
	look_vec = (current_target.global_position - global_position).normalized()
	if !_in_vision_cone(current_target.global_position) or !has_los(current_target):
		if current_target in $Cqb_awareness.get_overlapping_bodies():
			return
		for enemy in nearby_enemies:
			if _in_vision_cone(enemy.global_position) and has_los(enemy):
				current_target = enemy
				#print("blastin")
				$attack.start()
				get_parent().start_blastin(current_target)
				return
		get_parent().start_chasin()

func idle_state():
	look_vec = get_parent().direction
	if rng.randi_range(0,1) == 1:
		for enemy in nearby_enemies:
			if _in_vision_cone(enemy.global_position) and has_los(enemy):
				#print("blastin")
				$attack.start()
				get_parent().start_blastin(enemy)
func update_nearby_npcs():
	nearby_allies = []
	nearby_enemies = []
	for body in bodies:
		if body.is_in_group(group):
			nearby_allies.append(body)
		else:
			nearby_enemies.append(body)

func update_current_target():
	update_nearby_npcs()
	current_target = get_closest(nearby_enemies)
	if current_target == null:
		return false
	return true

func get_closest(array):
	var closest = null
	var smallest_distance = -1
	for body in array:
		var dist_to_body = global_position.distance_squared_to(body.global_position)
		if smallest_distance < 0 or dist_to_body < smallest_distance:
			closest = body
			smallest_distance = dist_to_body
	return closest


func get_self_circle_position():
	var kill_circle_centre = Vector2.ZERO
	var radius = 20
#	Distance from center to circumference of circle
	var angle = rng.randf() * PI * 2;
	var x = kill_circle_centre.x + cos(angle) * radius;
	var y = kill_circle_centre.y + sin(angle) * radius;
	return(Vector2(x,y))

func _in_vision_cone(point):
	var forward = ($Marker2D.global_position - global_position).normalized()
	var dir_to_point = point - global_position
	return abs(rad_to_deg(dir_to_point.angle_to(forward))) <= angle_cone_of_vission

func has_los(target):
	ray.global_position = $Marker2D.get_child(0).get_point_of_fire()
	var vectooor = target.global_position - $Marker2D.get_child(0).get_point_of_fire()
	ray.target_position = vectooor.normalized() * max_viev_distance
	ray.force_raycast_update()
	if ray.is_colliding() and ray.get_collider() == target:
		return true
	return false

func apply_recoil(recoil_vector):
	if !current_target: return
	get_parent().get_children()[-1].apply_recoil(recoil_vector)
func set_handling_spd(weight):
	get_parent().get_children()[-1].set_handling_spd(weight)

func flip():
	get_parent().flip()
	flipped = !flipped
	scale.y *= -1

func reload():
	$Marker2D.get_child(0).reload()

func _on_attack_timeout() -> void:
	if !current_target or !is_instance_valid(current_target): return
	if _in_vision_cone(current_target.global_position) and has_los(current_target):
		#print("gud")
		$Marker2D.get_child(0).start_fire()
		$burst_duration.start()
	#print("bad ", _in_vision_cone(current_target.global_position), has_los(current_target.global_position))


func _on_burst_duration_timeout() -> void:
	$Marker2D.get_child(0).stop_fire()
