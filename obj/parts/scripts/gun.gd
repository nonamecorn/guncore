extends Item

class_name GunResource

@export var modules : Dictionary[String,Item]

func remove_module(slot_name : String) -> Item:
	var item = modules[slot_name]
	modules[slot_name] = null
	modules_changed.emit()
	return item

func equip_module(item : Item, slot_name : String) -> Item:
	var ret_item : Item = null
	if modules[slot_name] != null:
		ret_item = modules[slot_name]
	modules[slot_name] = item
	modules_changed.emit()
	return ret_item

signal modules_changed
