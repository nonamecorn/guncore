extends Item
class_name Attachment

@export var attach_node : PackedScene
@export var is_underbarrel : bool
var needs_facade : bool


func _init():
	needs_facade = !is_instance_valid(attach_node) 
	slot = "ATTACH"
