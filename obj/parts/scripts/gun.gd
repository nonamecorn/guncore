extends Item

class_name GunResource

@export var modules : Dictionary[String,Item] = {
	"MAG": null,
	"BARREL": null,
	"MUZZLE": null,
	"ATTACH": null,
}
var ammo
signal modules_changed(modules)
@warning_ignore("unused_signal")
signal drop

func _init():
	slot = "GUN"

func set_module(item : Item, slot_name : String) -> void:
	modules[slot_name] = item
	modules_changed.emit(modules)
