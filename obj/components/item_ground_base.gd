extends StaticBody2D

var item_resource : Item

func init(item):
	item_resource = item
	$Sprite2D.texture = item.sprite
