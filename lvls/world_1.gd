extends Node2D

var exits = []
var rects = []
var room_obj = preload("res://lvls/rooms/basic_room.tscn")
var exit_obj = preload("res://lvls/rooms/exit_room.tscn")
var corr_north_obj = preload("res://lvls/corridors/verticalnorth_corr.tscn")
var corr_west_obj = preload("res://lvls/corridors/horisontwest_corr.tscn")
var corr_east_obj = preload("res://lvls/corridors/horisonteast_corr.tscn")
var corr_south_obj = preload("res://lvls/corridors/verticalsouth_corr.tscn")
@export var roomcount = 10
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rects.append($"modules/starting room".get_rect())
	spawn()

func get_exits():
	exits = get_tree().get_nodes_in_group("connector").filter(func(element): return element.type == 1 and element.active)

func get_closing_exits():
	exits = get_tree().get_nodes_in_group("connector").filter(func(element): return element.type == 1)

func spawn():
	$make_room.start()

func room_fits(room_rect, corr_rect):
	for rect in rects:
		if room_rect.intersects(rect) or corr_rect.intersects(rect):
			return false
	return true

func stop_spawnin():
	get_exits()
	exits.reverse()
	for exit in exits:
		var connector_info = exits[0].get_info()
		var corr_inst
		var connector_to_destroy
		match connector_info[1]:
			0: 
				corr_inst = corr_north_obj.instantiate()
				connector_to_destroy = 3
			1: 
				corr_inst = corr_west_obj.instantiate()
				connector_to_destroy = 2
			2: 
				corr_inst = corr_east_obj.instantiate()
				connector_to_destroy = 1
			3: 
				corr_inst = corr_south_obj.instantiate()
				connector_to_destroy = 0
		corr_inst.global_position = connector_info[2]
		var corr_connector = corr_inst.get_child(0).get_child(0)
		$modules.add_child(corr_inst)
		var exit_inst = exit_obj.instantiate()
		exit_inst.global_position = corr_connector.global_position
		$modules.add_child(exit_inst)
		exit_inst.align(connector_info[1])
		var room_rect = exit_inst.get_rect()
		room_rect.position = room_rect.position
		var corr_rect = corr_inst.get_rect()
		if !room_fits(room_rect,corr_rect):
			exits[0].active = false
			exit_inst.queue_free()
			corr_inst.queue_free()
			continue
		exit_inst.get_child(0).get_child(connector_to_destroy).queue_free()
		break
	
	$Camera2D.enabled = false
	$Player/Camera2D.enabled = true
	
	
	get_closing_exits()
	for exit in exits:
		exit.close()

func _on_make_room_timeout() -> void:
	if  roomcount == 0:
		$make_room.stop()
		stop_spawnin()
		return
	get_exits()
	exits.shuffle()
	var connector_info = exits[0].get_info()
	var corr_inst
	var connector_to_destroy
	match connector_info[1]:
		0: 
			corr_inst = corr_north_obj.instantiate()
			connector_to_destroy = 3
		1: 
			corr_inst = corr_west_obj.instantiate()
			connector_to_destroy = 2
		2: 
			corr_inst = corr_east_obj.instantiate()
			connector_to_destroy = 1
		3: 
			corr_inst = corr_south_obj.instantiate()
			connector_to_destroy = 0
	corr_inst.global_position = connector_info[2]
	var corr_connector = corr_inst.get_child(0).get_child(0)
	$modules.add_child(corr_inst)
	var room_inst = room_obj.instantiate()
	room_inst.global_position = corr_connector.global_position
	$modules.add_child(room_inst)
	room_inst.align(connector_info[1])
	var room_rect = room_inst.get_rect()
	room_rect.position = room_rect.position
	var corr_rect = corr_inst.get_rect()
	if !room_fits(room_rect,corr_rect):
		exits[0].active = false
		room_inst.queue_free()
		corr_inst.queue_free()
		return
	room_inst.get_child(0).get_child(connector_to_destroy).queue_free()
	rects.append_array([room_rect, corr_rect])
	roomcount -= 1
	
