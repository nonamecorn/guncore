extends Node2D

var exits = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func get_exits():
	for module in $modules.get_children():
		module.get_exits()

func spawn():
	pass
