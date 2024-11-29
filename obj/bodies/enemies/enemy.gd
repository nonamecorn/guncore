extends CharacterBody2D

const MAX_SPEED = 110
const ACCELERATION = 700
const FRICTION = 700

var randomnum
var bodies = []
var dead = false
enum {
	SURROUND,
	CHASE,
	IDLE
}
var bug = false
var health = 3
var state = IDLE
var rng = RandomNumberGenerator.new()
var player = null
@export var nav_agent: NavigationAgent2D

func _ready():
#	print(movement_target)
	rng.randomize()
	randomnum = rng.randf()

func set_movement_target(target_point: Vector2):
	nav_agent.target_position = target_point

func _physics_process(delta):
	if dead:
		return
	match state:
		SURROUND:
			surround(get_circle_position(randomnum), delta)
		CHASE:
			move(delta)

func move(delta):
	if nav_agent.is_navigation_finished():
		return
	if $enemy_hand_component.bodies.size() > 0:
		state = SURROUND
	var current_pos = global_position
	var next_path = nav_agent.get_next_path_position()
	var new_velocity = (next_path - current_pos).normalized()
	
	velocity = velocity.move_toward(new_velocity * MAX_SPEED,delta * ACCELERATION)
	move_and_slide()

func surround(target,delta):
	var direction = (target - global_position).normalized() 
	velocity = velocity.move_toward(direction * MAX_SPEED,delta * ACCELERATION)
	move_and_slide()

func get_circle_position(random):
	var kill_circle_centre = bodies[0].global_position
	var radius = 200

#	Distance from center to circumference of circle
	var angle = random * PI * 2;
	var x = kill_circle_centre.x + cos(angle) * radius;
	var y = kill_circle_centre.y + sin(angle) * radius;
	return(Vector2(x,y))

func _on_makepath_timeout():
	if !dead and !bug:
		set_movement_target(bodies[0].position)

func _on_sight_body_entered(body):
	if body.is_in_group("player") and !dead:
		bodies.append(body)
		state = SURROUND
		


func _on_sight_body_exited(body):
	if body in bodies and !dead:
		state = CHASE
		bodies.erase(body)
		

func fucking_shit():
	state = IDLE
	bodies = []
	bug = true
	$makepath.stop()

func _on_change_position_timeout():
	randomnum = rng.randf()

func hurt(value):
	health -= value
	if health <= 0:
		call_deferred("die")
	

func die():
	dead = true
	state = IDLE
	$change_position.stop()
	$makepath.stop()
	$CollisionShape2D.disabled = true
	$enemy_hand_component.queue_free()
#	movement_target = null
	$Sprite2D.rotation_degrees = 90

func _on_agro_zone_body_entered(body: Node2D) -> void:
	if !body.is_in_group("player") or dead:
		return
	if player == null:
		body.died.connect(fucking_shit)
	player = body
	$makepath.start()
	bodies.append(body)
	state = CHASE
	set_movement_target(body.position)
