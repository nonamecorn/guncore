extends Node2D

var exits = []
var room_obj = preload("res://lvls/rooms/basic_room.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func get_exits():
	exits = get_tree().get_nodes_in_group("connector")

func spawn():
	get_exits()
	exits.shuffle()
	var connector = exits[1].pop()
	if connector[0] == 0: #corr
		var room_inst = room_obj.instantiate()
		room_inst.global_position = $mods_markers.check_point_of_fire()
		$modules.add_child(room_inst)
	else:
		pass
