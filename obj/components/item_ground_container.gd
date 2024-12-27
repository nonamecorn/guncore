extends Area2D

@export var item_resources : Array[Item] 

func init(item):
	pass
	#item_resource = item.duplicate()
	#item_resource.pickup.connect(destroy)
	#item_resource.id = IdGiver.get_id()

func pickup() -> Array[Item]:
	return(item_resources)

func destroy():
	queue_free()
