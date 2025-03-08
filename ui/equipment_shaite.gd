extends TextureRect

var items = {}
 
signal assemble(parts,loaded)
signal dissassemble
signal change(parts)

@export var gun = true

var quick_reload = true

func _ready():
	for slot in get_children():
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
	if item.item_resource.from_shop:
		if  GlobalVars.money >= item.item_resource.cost:
			get_parent().get_parent().buy_item()
		else: return false
	item.item_resource.pickup.emit()
	if !item.item_resource.destroy.is_connected(destroy_item):
		item.item_resource.destroy.connect(destroy_item)
	items[item_slot] = item
	if gun:
		check_assembly()
	else:
		change.emit(get_gear())
	item.item_resource.eq = true
	item.item_resource.eq_index = get_index()
	item.item_resource.pick_up()
	item.global_position = slot.global_position + slot.size / 2 - item.size / 2
	find_child(item_slot+"COVER"+str(get_index())).show()
	return true
 
func insert_item_at_spot(item, slot):
	if slot == null or !find_child(slot):
		return false
	var item_slot = item.item_resource.slot
	if item_slot != slot:
		return false
	if items.has(item_slot) and items[item_slot] != null:
		return false
	items[item_slot] = item
	if gun:
		check_assembly()
	else:
		change.emit(get_gear())
	item.item_resource.eq = true
	item.item_resource.eq_index = get_index()
	item.item_resource.pick_up()
	if !item.item_resource.destroy.is_connected(destroy_item):
		item.item_resource.destroy.connect(destroy_item)
	var da_slot = find_child(slot)
	var item_pos = da_slot.get("global_position") + da_slot.get("size") / 2 - item.size / 2
	item.global_position = item_pos
	find_child(item_slot+"COVER"+str(get_index())).show()
	return true

func occupied(item):
	var item_pos = item.global_position + item.size / 2
	var slot = get_slot_under_pos(item_pos)
	if slot == null:
		return false
	var item_slot = item.item_resource.slot
	if items.has(item_slot) and items[item_slot] != null:
		return true
	return false

func grab_item(pos):
	var item = get_item_under_pos(pos)
	if item == null:
		return null
	item.item_resource.eq = false
	var item_slot = item.item_resource.slot
	items[item_slot] = null
	if gun:
		check_dissassembly()
	else:
		change.emit(get_gear())
	find_child(item_slot+"COVER"+str(get_index())).hide()
	return item
 
func grab_item_at_spot(slot):
	var item = items[slot]
	if item == null:
		return null
	item.item_resource.eq = false
	var item_slot = item.item_resource.slot
	items[item_slot] = null
	if gun:
		check_dissassembly()
	else:
		change.emit(get_gear())
	find_child(item_slot+"COVER"+str(get_index())).hide()
	return item

func get_slot_under_pos(pos):
	return get_thing_under_pos(get_children(), pos)
 
func get_item_under_pos(pos):
	return get_thing_under_pos(items.values(), pos)
 
func get_thing_under_pos(arr, pos):
	for thing in arr:
		if thing != null and thing.get_global_rect().has_point(pos):
			return thing
	return null

func check_assembly():
	if items["RECIEVER"] and items["BARREL"] and items["MAG"]:
		assemble.emit(get_parts(),quick_reload)

func check_dissassembly():
	if !items["RECIEVER"] or !items["BARREL"] or !items["MAG"]:
		dissassemble.emit()
		return
	assemble.emit(get_parts(),quick_reload)

func destroy_item(slot):
	var item = grab_item_at_spot(slot)
	item.item_resource.destroy.disconnect(destroy_item)
	item.queue_free()

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
	
func get_gear():
	
	var parts = {
		"BODY": null,
		"HEAD": null,
		"HAND": null,
	}
	for part in items:
		if !items[part]: continue
		parts[part] = items[part].item_resource
	return parts
