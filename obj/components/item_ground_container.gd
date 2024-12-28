extends Area2D

@export var item_resources : Array[Item]
@export var slice : Array[int] = [0, 100]

func _ready():
	var items = []
	for item in Randogunser.shop_pool:
		items.append(load(item))
	for item in Randogunser.recievers:
		items.append(load(item))
	for item in Randogunser.mags:
		items.append(load(item))
	for item in Randogunser.barrels:
		items.append(load(item))
	item_resources.append_array(items.slice(slice[0], slice[1]))

func init(item):
	pass
	#item_resource = item.duplicate()
	#item_resource.pickup.connect(destroy)
	#item_resource.id = IdGiver.get_id()

func pickup() -> Array[Item]:
	return(item_resources)

func destroy():
	queue_free()
