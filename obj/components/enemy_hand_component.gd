extends Node2D

@export var hand_length = 80
var bodies = []
var state = IDLE
enum {
	FIRING,
	IDLE
}

func _ready() -> void:
	$Marker2D.position.x = hand_length
	$Marker2D.get_child(0).empty.connect(reload)

var flipped = false

func _process(_delta):
	match state:
		IDLE:
			pass
		FIRING:
			var look_vec = bodies[0].global_position - global_position
			if look_vec.x < 0 and !flipped:
				flip()
			if look_vec.x >= 0 and flipped:
				flip()
			global_rotation = atan2(look_vec.y, look_vec.x)

func _on_sight_body_entered(body):
	if body.is_in_group("player"):
		bodies.append(body)
		state = FIRING
		$attack.start()
		$Marker2D.get_child(0).fire()

func _on_sight_body_exited(body):
	if body in bodies:
		bodies.erase(body)
		if bodies.size() == 0:
			state = IDLE
			$attack.stop()

func flip():
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
	$Marker2D.get_child(0).fire()
