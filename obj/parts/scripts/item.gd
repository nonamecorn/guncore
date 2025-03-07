extends Resource
class_name Item


@export var item_name : String = ""
@export_multiline var item_description : String = ''
@export var cost : int = 5
@export var max_durability : float = 1000.0
@export var curr_durability : float = 1000.0:
	set(val):
		damaged.emit()
		curr_durability = val
		broken = curr_durability<=0
	get():
		return curr_durability
@export var sprite : Texture2D
@export var sprite_offset : Vector2
@export var bullet_strategies : Array[BasicBulletStrategy]
@export var player_strategies : Array[BasicPlayerStrategy]
@export var shootin_strategies : Array[BasicShootingStratagy]
@export var changes : Array[Change]
@export var weight : float = 1.0

var from_shop = false
var id : int
var slot
signal pickup
signal damaged
signal destroy(slot)

var eq = false
var eq_index = null
var picked_up = false
var broken = false

func destroy_item():
	GlobalVars.items.erase(self)
	destroy.emit(slot)

func init():
	id = IdGiver.get_id()

func pick_up():
	if picked_up: return
	picked_up = true
	GlobalVars.items.append(self)
	pickup.emit()
