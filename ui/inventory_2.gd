extends Control

signal drop(item)
var data_bk
func _notification (what: int) -> void:
	if what == Node. NOTIFICATION_DRAG_BEGIN:
		data_bk = get_viewport().gui_get_drag_data()
	if what == Node. NOTIFICATION_DRAG_END:
		if not is_drag_successful():
			if data_bk:
				data_bk.icon.update_ui()
				data_bk = null

func pickup_gun(res: Item, slot : int = 0):
	$GunSlots.get_child(slot).equip_gun(res)

func pickup_item(item : Item) -> bool:
	for cell in $Backpack.get_children():
		if !cell.item:
			cell.item = item
			cell.update_ui()
			item.pick_up()
			return true
	return false

func _can_drop_data(_at_position: Vector2, _data: Variant) -> bool:
	return true

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	data.item.pickup.emit()
	drop.emit(data.item)
	data.item = null
