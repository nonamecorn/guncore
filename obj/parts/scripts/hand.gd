extends Item
class_name Hand
var slot : String = "HAND"

@export var throwable : PackedScene

enum types {Throw = 1, Inject = 2}
@export var type : types = types.Throw

signal used

func use():
	used.emit()
