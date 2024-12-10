extends Node2D

@export var hand_length = 34

func _ready() -> void:
	$Marker2D.position.x = hand_length
	$Marker2D.get_child(0).empty.connect(reload)

func attack():
	$attack.start()
func cease_fire():
	$attack.stop()

func reload():
	$Marker2D.get_child(0).reload()

func _on_attack_timeout() -> void:
	$Marker2D.get_child(0).start_fire()
	$burst_duration.start()

func _on_burst_duration_timeout() -> void:
	$Marker2D.get_child(0).stop_fire()
