extends Node2D

@export var hand_length = 80
var state = IDLE
var look_vec = Vector2.ZERO
var angle_cone_of_vission = 30
var angle_between_rays = 10
var max_viev_distance = 600
var current_target
@export var ray : Node 
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

func _physics_process(_delta: float) -> void:
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
	global_rotation = atan2(look_vec.y, look_vec.x)

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
	ray.target_position = point - global_position
	ray.force_raycast_update()
	if ray.is_colliding() and ray.get_collider() == get_parent().current_target:
		return true
	return false

func flip():
	get_parent().flip()
	flipped = !flipped
	scale.y *= -1

func add_gun(_gun):
	pass

func del_gun():
	pass

func switch_gun(gun):
	return gun
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
