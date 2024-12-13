extends Resource
class_name Item


@export var item_name : String = ""
@export_multiline var item_description : String = ''
@export var cost : int = 5
@export var sprite : Texture2D
@export var sprite_offset : Vector2
@export var bullet_strategies : Array[BasicBulletStrategy]
@export var player_strategies : Array[BasicPlayerStrategy]
@export var shootin_strategies : Array[BasicShootingStratagy]
@export var changes : Array[Change]

var from_shop = false
var id : int
signal pickup
var eq = false
var eq_index = null
var picked_up = false

func pick_up():
	if picked_up: return
	picked_up = true
	GlobalVars.items.append(self)
	pickup.emit()
