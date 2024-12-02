extends NinePatchRect

@onready var slots = get_children()
var items = {}
 
signal assemble(parts)
signal dissassemble

func _ready():
	for slot in slots:
		items[slot.name] = null

func insert_item(item):
	var item_pos = item.global_position + item.size / 2
	var slot = get_slot_under_pos(item_pos)
	if slot == null:
		return false
	var item_slot = item.item_resource.slot
	if item_slot != slot.name:
		return false
	if items[item_slot] != null:
		return false
	items[item_slot] = item
	item.global_position = slot.global_position + slot.size / 2 - item.size / 2
	check_assembly()
	return true
 
func grab_item(pos):
	var item = get_item_under_pos(pos)
	if item == null:
		return null
 
	var item_slot = item.item_resource.slot
	items[item_slot] = null
	check_dissassembly()
	return item
 
func get_slot_under_pos(pos):
	return get_thing_under_pos(slots, pos)
 
func get_item_under_pos(pos):
	return get_thing_under_pos(items.values(), pos)
 
func get_thing_under_pos(arr, pos):
	for thing in arr:
		if thing != null and thing.get_global_rect().has_point(pos):
			return thing
	return null

func check_assembly():
	if items["RECIEVER"] and items["BARREL"] and items["MAG"]:
		assemble.emit(get_parts())

func check_dissassembly():
	if !items["RECIEVER"] or !items["BARREL"] or !items["MAG"]:
		dissassemble.emit()
		return
	assemble.emit(get_parts())
	

func get_parts():
	
	var parts = {
		"RECIEVER": null,
		"BARREL": null,
		"MAG": null,
		"MUZZLE": null,
		"MOD1": null,
		"MOD2": null,
	}
	for part in items:
		if !items[part]: continue
		parts[part] = items[part].item_resource
	return parts
