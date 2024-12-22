extends Item
class_name Barrel
@export var range_in_secs : float
@export var max_spread : float
@export var min_spread : float
@export var muzzle_position : Vector2
@export var add_spd : float
var slot : String = "BARREL"
var stats = {
	"Range": "range_in_secs",
	"Max Spread": "max_spread",
	"Min Spread": "min_spread",
	"Added Speed": "add_spd",
}
