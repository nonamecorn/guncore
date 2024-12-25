extends Node2D

@export var hand_length = 80
var state = IDLE
var look_vec = Vector2.ZERO
var angle_cone_of_vission = 30
var angle_between_rays = 10
var max_viev_distance = 600
var current_target
@export var ray : Node
@export var particles : Node 
@export var turn_speed = 200.0
enum {
	FIRING,
	IDLE,
	RUN
}

var rng = RandomNumberGenerator.new()

func _ready() -> void:
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
	if !current_target or !is_instance_valid(current_target):
		return
	match state:
		IDLE:
			idle_state()
		FIRING:
			firing_state()
		RUN:
			run_state()
	if look_vec.x < 0 and !flipped:
		flip()
	if look_vec.x >= 0 and flipped:
		flip()
	face_point(delta)
	

func firing_state():
	look_vec = (current_target.global_position - global_position).normalized()
	if !_in_vision_cone(current_target.global_position) or !has_los(current_target.global_position):
		#print("runnin")
		state = RUN
		get_parent().start_chasin()

func idle_state():
	look_vec = get_parent().direction
	if _in_vision_cone(current_target.global_position) and has_los(current_target.global_position):
		#print("blastin")
		state = FIRING
		$attack.start()
		get_parent().start_blastin()

func run_state():
	look_vec = (current_target.global_position - global_position).normalized()
	if _in_vision_cone(current_target.global_position) and has_los(current_target.global_position):
		#print("blastin")
		state = FIRING
		$attack.start()
		get_parent().start_blastin()

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

func has_los(point):
	ray.global_position = $Marker2D.get_child(0).get_point_of_fire()
	ray.target_position = point - global_position
	ray.force_raycast_update()
	if ray.is_colliding() and ray.get_collider() == get_parent().current_target:
		return true
	return false

func apply_recoil(recoil_vector):
	if !current_target: return
	var direction = (current_target.global_position - global_position) + recoil_vector
	var angle = transform.x.angle_to(direction)
	rotate(abs(angle))

func flip():
	get_parent().flip()
	flipped = !flipped
	scale.y *= -1

func reload():
	$Marker2D.get_child(0).reload()

func _on_attack_timeout() -> void:
	if !current_target or !is_instance_valid(current_target): return
	if _in_vision_cone(current_target.global_position) and has_los(current_target.global_position):
		#print("gud")
		$Marker2D.get_child(0).start_fire()
		$burst_duration.start()
	#print("bad ", _in_vision_cone(current_target.global_position), has_los(current_target.global_position))


func _on_burst_duration_timeout() -> void:
	$Marker2D.get_child(0).stop_fire()
