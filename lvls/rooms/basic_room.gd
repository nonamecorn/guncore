extends Node2D

@onready var markers = $markers.get_children()


# Called when the node enters the scene tree for the first time.
func get_exits() -> Array:
	return markers
