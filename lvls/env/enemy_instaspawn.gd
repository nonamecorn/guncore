extends Node2D

@export var enemy: PackedScene

func init():
	var enemy_inst = enemy.instantiate()
	enemy_inst.state = 1
	enemy_inst.global_position = global_position
	get_tree().current_scene.find_child("enemies").call_deferred("add_child",enemy_inst)
