extends VBoxContainer

var resource : GunResource

func _ready() -> void:
	for cell in $HBoxContainer.get_children():
		cell.item_changed.connect(on_change.bind(cell.type))

func equip_gun(res : GunResource):
	$InventoryCell.set_deferred("item", res)
	await get_tree().process_frame
	$InventoryCell.call_deferred("update_ui")
	resource = res
	resource.drop.connect(on_drop)
	load_modules(res)
	for cell in $HBoxContainer.get_children():
		cell.disabled = false
	

func load_modules(res):
	for cell in $HBoxContainer.get_children():
		cell.item = res.modules[cell.type]

func on_drop():
	resource.drop.disconnect(on_drop)
	$InventoryCell.item = null
	$InventoryCell.update_ui()
	for cell in $HBoxContainer.get_children():
		cell.disabled = true
		cell.item = null
		cell.update_ui()

func on_change(item : Item, slot : String):
	resource.set_module(item,slot)
