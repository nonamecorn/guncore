extends NinePatchRect

@onready var slots = get_children()
var items = {
	"0": null,
	"1": null,
	"2": null,
	"3": null,
	"4": null,
	"5": null,
}
@export var slot_id : int
signal change

func _ready():
	for slot in slots:
		items[slot.name] = null

func insert_item(item):
	var item_pos = item.global_position + item.size / 2
	var slot = get_slot_under_pos(item_pos)
	if slot == null:
		return false
	var item_slot = item.item_resource.slot
	if item_slot != "AUGMENT":
		return false
	var slot_num = slot.get_index()
	if items[slot_num] != null:
		return false
	items[slot_num] = item
	item.global_position = slot.global_position + slot.size / 2 - item.size / 2
	change.emit(get_parts())
	return true
 
func occupied(item):
	var item_pos = item.global_position + item.size / 2
	var slot = get_slot_under_pos(item_pos)
	if slot == null:
		return false
	var item_slot = item.item_resource.slot
	if items[item_slot] != null:
		return true
	return false

func grab_item(pos):
	var item = get_item_under_pos(pos)
	if item == null:
		return null
 
	var item_slot = item.item_resource.slot
	items[item_slot] = null
	change.emit(get_parts())
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

func get_parts():
	var parts = []
	for part in items:
		if !items[part]: continue
		parts.append(items[part].item_resource)
	return parts
