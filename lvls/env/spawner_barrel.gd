extends CharacterBody2D

@export var enemy = load("res://obj/bodies/enemies/enemy.tscn")
@export var hand_rotation : float = 0.0

func _ready() -> void:
	$hand.rotate(rad_to_deg(hand_rotation))

func hurt(_amnt):
	$AudioStreamPlayer2D.play()
	
	var enemy_inst = enemy.instantiate()
	enemy_inst.global_position = $hand/Marker2D.global_position
	get_tree().current_scene.find_child("enemies").call_deferred("add_child",enemy_inst)
