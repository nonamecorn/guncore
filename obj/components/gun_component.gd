extends Node2D

@onready var player_logic = $player_logic_component
@onready var enemy_logic = $enemy_logic_component

var max_ammo = 30
var current_ammo = 30
var bullet_obj = preload("res://obj/proj/fmj.tscn")
var point_of_shooting = Vector2(0,0)

func _on_player_logic_component_fire() -> void:
	fire()


func fire():
	print("pow")
	if current_ammo <= 0:
		current_ammo = max_ammo
#		$reload.start()
#		get_parent().state = 1
	if current_ammo > 0:
		current_ammo -= 1
		var bullet_inst = bullet_obj.instantiate()
		bullet_inst.global_position = $mods_markers.check_point_of_fire()
		bullet_inst.global_rotation = global_rotation
		bullet_inst.init(get_parent().get_parent().get_parent().velocity)
		get_tree().current_scene.add_child(bullet_inst)
