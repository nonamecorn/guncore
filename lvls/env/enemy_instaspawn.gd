extends Node2D

@export var enemy = load("res://obj/bodies/enemies/corp_grunt.tscn")

func _ready() -> void:
	var enemy_inst = enemy.instantiate()
	enemy_inst.state = 1
	enemy_inst.global_position = global_position
	get_tree().current_scene.find_child("enemies").call_deferred("add_child",enemy_inst)

func init() -> void:
	pass
