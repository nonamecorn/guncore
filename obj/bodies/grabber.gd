extends Area2D

var item : Gun
var dropping : bool = false

func _process(_delta):
	if Input.is_action_just_pressed("ui_rclick"):
		if !item:
			for p_item in get_overlapping_bodies():
				item = p_item
				pickup()
				break
		elif !dropping:
			drop()

func pickup():
	item.call_deferred("reparent",get_parent())
	item.set_deferred("position", Vector2.ZERO)
	get_parent().get_parent().activate_gun(item)

func drop():
	if item.firing or item.reloading:
		return
	dropping = true
	get_parent().get_parent().deactivate_gun()
	item.item_resource.drop.emit()
	item.stop_fire()
	var items_node : Node = get_tree().current_scene.find_child("items")
	item.global_position = global_position
	item.call_deferred("reparent",items_node)
	item = null
	dropping = false
