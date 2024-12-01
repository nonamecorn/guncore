extends Control
 
const item_base = preload("res://ui/item_base.tscn")
 
@export var grid_bkpk : Node
@export var eq_slots : Node
@export var collector : Node

var item_held = null
var item_offset = Vector2()
var last_container = null
var last_pos = Vector2()
 
func _ready():
	pickup_item(load("res://obj/parts/guns/akm.tres"))
	pickup_item(load("res://obj/parts/barrels/long_barrel.tres"))
 
func _process(_delta):
	var cursor_pos = get_global_mouse_position()
	if Input.is_action_just_pressed("ui_left_mouse"):
		grab(cursor_pos)
	if Input.is_action_just_released("ui_left_mouse"):
		release(cursor_pos)
	if item_held != null:
		item_held.global_position = cursor_pos + item_offset
		if Input.is_action_just_released("reload"):
			item_held.global_position = cursor_pos
			item_held.rotate()
			item_offset = Vector2(item_held.size.x, item_held.size.y)
			#item_held.global_position = cursor_pos #+ Vector2(item_held.size.x, item_held.size.y)
 
func grab(cursor_pos):
	var c = get_container_under_cursor(cursor_pos)
	if c != null and c.has_method("grab_item"):
		item_held = c.grab_item(cursor_pos)
		if item_held != null:
			last_container = c
			last_pos = item_held.global_position
			item_offset = item_held.global_position - cursor_pos
			move_child(item_held, get_child_count())
 
func release(cursor_pos):
	if item_held == null:
		return
	var c = get_container_under_cursor(cursor_pos)
	if c == null:
		drop_item()
	elif c.has_method("insert_item"):
		if c.insert_item(item_held):
			item_held = null
		else:
			return_item()
	else:
		return_item()
 
 
func get_container_under_cursor(cursor_pos):
	var containers = [grid_bkpk, eq_slots, collector]
	for c in containers:
		if c.get_rect().has_point(cursor_pos):
			return c
	return null
 
func drop_item():
	item_held.queue_free()
	item_held = null
 
func return_item():
	item_held.global_position = last_pos
	last_container.insert_item(item_held)
	item_held = null
 
func pickup_item(item_res : Item):
	var item = item_base.instantiate()
	item.item_resource = item_res
	item.texture = item_res.previev
	add_child(item)
	if !grid_bkpk.insert_item_at_first_available_spot(item):
		item.queue_free()
		return false
	return true
