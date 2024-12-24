extends Node2D

var exits = []
var rects = []
var room_obj_path = "res://lvls/rooms/basic_room.tscn"
var exit_obj_path = "res://lvls/rooms/exit_room.tscn"
var corr_north_obj = preload("res://lvls/corridors/verticalnorth_corr.tscn")
var corr_west_obj = preload("res://lvls/corridors/horisontwest_corr.tscn")
var corr_east_obj = preload("res://lvls/corridors/horisonteast_corr.tscn")
var corr_south_obj = preload("res://lvls/corridors/verticalsouth_corr.tscn")
var rooms0 = [
	"res://lvls/rooms/basic_room.tscn",
	"res://lvls/rooms/cultfort_room.tscn",
]
var rooms1 = [
	"res://lvls/rooms/combat_room.tscn",
	"res://lvls/rooms/corpbreach_room.tscn",
	"res://lvls/rooms/combat_room.tscn",
]
var rooms = [
	"res://lvls/rooms/basic_room.tscn",
	"res://lvls/rooms/combat_room.tscn",
	"res://lvls/rooms/cultfort_room.tscn",
	"res://lvls/rooms/cultinvasion_room.tscn",
	"res://lvls/rooms/corpbreach_room.tscn",
]
@export var roomcount = 3
@export var debug = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rects.append($"modules/starting room".get_rect())
	OstManager.switch_track("Battle")
	if GlobalVars.loop >= 2:
		spawn()
		return
	
	rooms = get("rooms"+str(GlobalVars.loop))
	spawn()

func get_exits():
	exits = get_tree().get_nodes_in_group("connector").filter(func(element): return element.authorised and element.type == 1 and !element.known)

func get_closing_exits():
	exits = get_tree().get_nodes_in_group("connector").filter(func(element): return element.authorised and element.type == 1 and element.active)

func spawn():
	#$make_room.start()
	while roomcount != 0:
		rooms.shuffle()
		spawn_room(rooms[0])
	#$make_room.stop()
	#stop_spawnin()
	#return
	
	
	while roomcount == 0:
		spawn_room(exit_obj_path)
	get_closing_exits()
	for exit in exits:
		#if exit.active: continue
		exit.close()
	if !debug: 
		$Camera2D.enabled = false
		$ysort/enemies/Player/Camera2D.enabled = true
	$CanvasLayer/ColorRect.hide()

func room_fits(room_rect, corr_rect):
	for rect in rects:
		if room_rect.intersects(rect) or corr_rect.intersects(rect):
			return false
	return true

func stop_spawnin():
	
	while roomcount == 0:
		spawn_room(exit_obj_path)
	#$Camera2D.enabled = false
	#$ysort/enemies/Player/Camera2D.enabled = true
	
	get_closing_exits()
	for exit in exits:
		exit.close()

func spawn_room(room : String):
	get_exits()
	exits.reverse()
	var head = exits.slice(0,3)
	head.shuffle()
	var connector = head[0]
	var connector_info = connector.get_info()
	if !connector_info:
		return
	var corr_inst
	var connector_to_destroy
	match connector_info.orientation:
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
	corr_inst.global_position = connector_info.position
	var corr_connector = corr_inst.get_child(0).get_child(0)
	$modules.add_child(corr_inst)
	var room_inst = load(room).instantiate()
	room_inst.global_position = corr_connector.global_position
	$modules.add_child(room_inst)
	room_inst.align(connector_info.orientation)
	var room_rect = room_inst.get_rect()
	#room_rect.position = room_rect.position
	var corr_rect = corr_inst.get_rect()
	if room_fits(room_rect,corr_rect):
		var opposite_marker = room_inst.find_child("markers").get_child(connector_to_destroy)
		opposite_marker.deactivate()
		connector.deactivate()
		rects.append_array([room_rect, corr_rect])
		authorize_access(room_inst.markers)
		opposite_marker.get_info()
		roomcount -= 1
	else:
		connector.close()
		room_inst.queue_free()
		corr_inst.queue_free()
		print("wtf")

func authorize_access(markers):
	for marker in markers:
		marker.authorised = true

func _on_make_room_timeout() -> void:
	if  roomcount == 0:
		$make_room.stop()
		stop_spawnin()
		return
	rooms.shuffle()
	spawn_room(rooms[0])
