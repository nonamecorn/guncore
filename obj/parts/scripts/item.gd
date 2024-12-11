extends Resource
class_name Item


@export var item_name : String = ""
@export_multiline var item_description : String = ''
@export var cost : int = 5
@export var sprite : Texture2D
@export var sprite_offset : Vector2
@export var bullet_strategies : Array[BasicBulletStrategy]
@export var firing_strategies : Array[BasicBulletStrategy]
@export var changes : Array[Change]

var from_shop = false
var id : int
signal pickup

func pick_up():
	GlobalVars.items.append(self)
	pickup.emit()

func equipslot(slot):
	GlobalVars.slot[slot].append(self)
	GlobalVars.items.erase(self)

func unequipslot(slot):
	GlobalVars.slot[slot].erase(self)
	GlobalVars.items.append(self)
