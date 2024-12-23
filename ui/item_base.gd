extends TextureRect

@export var item_resource : Item

@export var item_nametag : Node
@export var item_desctag : Node

@onready var durabar = $PopupPanel/MarginContainer2/MarginContainer/VBoxContainer/DurabilityBar

func _ready() -> void:
	item_nametag.text = item_resource.item_name
	item_desctag.text = item_resource.item_description + "\n cost: " + str(item_resource.cost)
	durabar.max_value = item_resource.durability
	if "stats" in item_resource:
		for stat in item_resource.stats:
			var statsting = "\n " + stat + ": "
			item_desctag.text += statsting + str(item_resource.get(item_resource.stats[stat]))
func _on_mouse_entered() -> void:
	durabar.value = item_resource.durability
	$PopupPanel.popup(Rect2i(Vector2i(get_global_mouse_position()), $PopupPanel.size) )

func _on_mouse_exited() -> void:
	$PopupPanel.hide()
