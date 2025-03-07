extends Item
class_name Hand

func _init():
	slot = "HAND"


func destroy_item():
	destroy.emit(slot)

@export var throwable : PackedScene

enum types {Throw = 1, Inject = 2}
@export var type : types = types.Throw
