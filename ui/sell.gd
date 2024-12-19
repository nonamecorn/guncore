extends NinePatchRect

func insert_item(item):
	if !item.item_resource.from_shop:
		GlobalVars.items.erase(item.item_resource)
		get_parent().sell_item()
		item.queue_free()
		return true
	else:
		return false
	
