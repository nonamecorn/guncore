extends Node2D

@onready var cultist = load("res://obj/bodies/enemies/enemy.tscn")
var enemy_count = 0
@export var number_of_enemies = 1
@export var initial_state = 2

func init():
	spawn()
	enemy_count += 1
	$Timer.start()

func spawn():
	if enemy_count >= number_of_enemies:
		queue_free()
		return
	var enemy_inst = cultist.instantiate()
	enemy_inst.state = initial_state
	enemy_inst.global_position = global_position
	get_tree().current_scene.find_child("enemies").call_deferred("add_child",enemy_inst)
	enemy_count += 1
