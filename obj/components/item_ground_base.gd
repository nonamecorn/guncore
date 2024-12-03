extends Area2D

var item_resource : Item

func init(item):
	item_resource = item.duplicate()
	item_resource.pickup.connect(destroy)
	$Sprite2D.texture = item.sprite
	item_resource.id = IdGiver.get_id()

func pickup() -> Item:
	return(item_resource)

func destroy():
	print(item_resource.id)
	queue_free()
