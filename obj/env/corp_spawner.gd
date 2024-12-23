extends Node2D

@onready var corp = load("res://obj/bodies/enemies/corp_grunt.tscn")
func init():
	$AnimationPlayer.play("doorkick")

func spawn():
	if has_node("corps"):
		for marker in $corps.get_children():
			var enemy_inst = corp.instantiate()
			enemy_inst.state = 2
			enemy_inst.global_position = marker.global_position
			get_tree().current_scene.find_child("enemies").call_deferred("add_child",enemy_inst) 
