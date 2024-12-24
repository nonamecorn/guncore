extends Node2D

@onready var corp = load("res://obj/bodies/enemies/corp_grunt.tscn")
@export var number_of_enemies : int
var enemy_count = 0
func init():
	$AnimationPlayer.play("doorkick")
	enemy_count+=1


func spawn():
	if enemy_count >= number_of_enemies:
		$Timer.stop()
		return
	var enemy_inst = corp.instantiate()
	enemy_inst.state = 2
	enemy_inst.global_position = $corps/Marker2D.global_position
	get_tree().current_scene.find_child("enemies").call_deferred("add_child",enemy_inst)
	enemy_count += 1
