extends Node2D

@export var hand_length = 80
var bodies = []
var state = IDLE
var look_vec = Vector2.ZERO
var angle_cone_of_vission = deg_to_rad(70)
var angle_between_rays = deg_to_rad(10)
var max_viev_distance = 600
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

func _process(_delta):
	
	
	match state:
		IDLE:
			var cast_count = int(angle_cone_of_vission / angle_between_rays) + 1
			for index in cast_count:
				var cast_vector = (
					max_viev_distance *
					Vector2.RIGHT.rotated(angle_between_rays * (index - cast_count / 2.0))
				)
				$RayCast2D.target_position = cast_vector
				$RayCast2D.force_raycast_update()
				if $RayCast2D.is_colliding() and $RayCast2D.get_collider().is_in_group("player"):
					print("huh")
					bodies.append($RayCast2D.get_collider())
					state = FIRING
					$attack.start()
					$Marker2D.get_child(0).fire()
					get_parent()._on_sight_body_entered($RayCast2D.get_collider())
					break
		FIRING:
			look_vec = bodies[0].global_position - global_position
			$RayCast2D.target_position = max_viev_distance * look_vec.normalized()
			$RayCast2D.force_raycast_update()
			if $RayCast2D.is_colliding() and !$RayCast2D.get_collider().is_in_group("player"):
				state = IDLE
				$attack.stop()
		RUN:
			look_vec = get_parent().direction
	if look_vec.x < 0 and !flipped:
		flip()
	if look_vec.x >= 0 and flipped:
		flip()
	global_rotation = atan2(look_vec.y, look_vec.x)


func _on_sight_body_entered(body):
	pass

func _on_sight_body_exited(body):
	pass
	#if body in bodies:
		#bodies.erase(body)
		#if bodies.size() == 0:
			#state = IDLE
			#$attack.stop()

func get_self_circle_position():
	var kill_circle_centre = Vector2.ZERO
	var radius = 20
#	Distance from center to circumference of circle
	var angle = rng.randf() * PI * 2;
	var x = kill_circle_centre.x + cos(angle) * radius;
	var y = kill_circle_centre.y + sin(angle) * radius;
	return(Vector2(x,y))

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
	$Marker2D.get_child(0).start_fire()
	$burst_duration.start()


func _on_burst_duration_timeout() -> void:
	$Marker2D.get_child(0).stop_fire()

func _on_look_around_timeout() -> void:
	match state:
		IDLE:
			look_vec = get_self_circle_position()
		FIRING:
			pass
