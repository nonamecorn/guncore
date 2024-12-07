extends Control
 

#
# INVENTORY
#


const item_base = preload("res://ui/item_base.tscn")
 
@export var grid_bkpk : Node
@export var eq_slot1 : Node
@export var eq_slot2 : Node
@export var augs : Node
@export var collector : Node
@export var safe_net : Node
@export var shop : Node
@export var shop_dil : Node
#var containers = [grid_bkpk, eq_slot1, eq_slot2, collector, augs, safe_net]

var item_held = null
var item_offset = Vector2()
var last_container = null
var last_pos = Vector2()

signal drop(item)

func load_save():
	for le_item in GlobalVars.items:
		pickup_item(le_item)
	for arrind in GlobalVars.slot.size():
		for item in GlobalVars.slot[arrind]:
			equip_item(item, arrind)

func _ready():
	pass
	#var gun = Randogunser.get_gun()
	#GlobalVars.items.append(load(gun.RECIEVER))
	#GlobalVars.items.append(load(gun.MAG))
	#GlobalVars.items.append(load(gun.BARREL))
	
	

func hide_popup():
	var items = $items.get_children()
	for c in items:
		c._on_mouse_exited()

func switch_to_shop():
	collector.hide()
	safe_net.show()
	shop.show()
	shop_dil.show()

func switch_to_inventory():
	collector.show()
	safe_net.hide()
	shop.hide()
	shop_dil.hide()

func _physics_process(_delta):
	if !visible: 
		return
	var cursor_pos = get_global_mouse_position()
	if Input.is_action_just_pressed("ui_left_mouse"):
		grab(cursor_pos)
	if Input.is_action_just_released("ui_left_mouse"):
		release(cursor_pos)
	if item_held != null:
		item_held.global_position = cursor_pos + item_offset
	check_popup(cursor_pos)
	
 
func grab(cursor_pos):
	var c = get_container_under_cursor(cursor_pos)
	if c != null and c.has_method("grab_item"):
		item_held = c.grab_item(cursor_pos)
		if item_held != null:
			$audio/grab.play()
			last_container = c
			last_pos = item_held.global_position
			item_offset = item_held.global_position - cursor_pos
 
func release(cursor_pos):
	if item_held == null:
		return
	var c = get_container_under_cursor(cursor_pos)
	if c == null:
		drop_item()
	elif c.has_method("occupied") and c.occupied(item_held):
		swap(c, cursor_pos)
	elif c.has_method("insert_item"):
		if c.insert_item(item_held):
			$audio/grab.play()
			item_held = null
		else:
			return_item()
	else:
		return_item()

func swap(c2, cursor_pos):
	var temp_item_held = c2.grab_item(cursor_pos)
	if temp_item_held == null: 
		return_item()
		return
	var temp_last_pos = temp_item_held.global_position
	if c2.insert_item(item_held):
		$audio/grab.play()
		item_held = null
		pickup_item(temp_item_held.item_resource)
		temp_item_held.queue_free()
	else:
		temp_item_held.global_position = temp_last_pos
		c2.insert_item(temp_item_held)
		return_item()

func check_popup(cursor_pos):
	var items = $items.get_children()
	for c in items:
		if c.get_global_rect().has_point(cursor_pos):
			c._on_mouse_entered()
		else:
			c._on_mouse_exited()

func get_container_under_cursor(cursor_pos):
	var active_containers = [grid_bkpk,
	 eq_slot1, eq_slot2,
	 collector, augs, shop,
	 safe_net].filter(func(thing): return thing.visible)
	for c in active_containers:
		if c.get_global_rect().has_point(cursor_pos):
			return c
	return null
 
func drop_item():
	drop.emit(item_held.item_resource)
	item_held.queue_free()
	item_held = null

func return_item():
	item_held.global_position = last_pos
	if last_container.has_method("insert_item"):
		last_container.insert_item(item_held)
	else:
		drop_item()
	item_held = null
	

func equip_item(item_res : Item, ind):
	var item = item_base.instantiate()
	item.item_resource = item_res
	item.texture = item_res.sprite
	$items.add_child(item)
	if !$equipments.get_child(ind).insert_item_at_spot(item, item_res.slot):
		item.queue_free()
		return false
	return true

func pickup_item(item_res : Item):
	var item = item_base.instantiate()
	item.item_resource = item_res
	item.texture = item_res.sprite
	$items.add_child(item)
	if !grid_bkpk.insert_item_at_first_available_spot(item):
		item.queue_free()
		return false
	return true

func pickup_collector(item_res : Item):
	var item = item_base.instantiate()
	item.item_resource = item_res
	item.texture = item_res.sprite
	$items.add_child(item)
	if !collector.insert_item_at_first_available_spot(item):
		item.queue_free()
		return false
	return true
