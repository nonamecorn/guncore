extends MarginContainer

@export var item_resource : Item

@export var item_nametag : Node
@export var item_desctag : Node

@export var durabar2 : Node

var texture
var desc_text = ""

@onready var durabar = $PopupPanel/MarginContainer2/MarginContainer/VBoxContainer/DurabilityBar

func _ready() -> void:
	$TextureRect.texture = texture
	desc_text+= "[font_size=16]" + item_resource.item_name + "[/font_size]\n\n"
	desc_text+=item_resource.item_description + "\n[color=Yellow] cost: " + str(item_resource.cost) + "$[/color]"
	#item_nametag.text = item_resource.item_name
	#item_desctag.text = item_resource.item_description + "\n cost: " + str(item_resource.cost) + "$"
	durabar.max_value = item_resource.max_durability
	durabar2.max_value = item_resource.max_durability
	durabar2.value = item_resource.curr_durability
	item_resource.damaged.connect(update)
	if "stats" in item_resource:
		for stat in item_resource.stats:
			var statsting = "\n " + stat + ": "
			desc_text += statsting + str(item_resource.get(item_resource.stats[stat]))

func update():
	durabar2.value = item_resource.curr_durability

func _on_mouse_entered() -> void:
	durabar.value = item_resource.curr_durability
	$PopupPanel.popup(Rect2i(Vector2i(get_global_mouse_position()), $PopupPanel.size) )

func _on_mouse_exited() -> void:
	$PopupPanel.hide()
