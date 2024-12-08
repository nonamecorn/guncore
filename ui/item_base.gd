extends TextureRect

@export var item_resource : Item

@export var item_nametag : Node
@export var item_desctag : Node
func _ready() -> void:
	item_nametag.text = item_resource.item_name
	item_desctag.text = item_resource.item_description + "\n cost: " + str(item_resource.cost)

func _on_mouse_entered() -> void:
	$PopupPanel.popup(Rect2i(Vector2i(get_global_mouse_position()), $PopupPanel.size) )

func _on_mouse_exited() -> void:
	$PopupPanel.hide()
