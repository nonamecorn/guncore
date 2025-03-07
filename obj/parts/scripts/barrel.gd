extends Item
class_name Barrel
@export var range_in_secs : float
@export var max_spread : float
@export var min_spread : float
@export var muzzle_position : Vector2
@export var add_spd : float


func _init():
	slot = "BARREL"

var stats = {
	"Range": "range_in_secs",
	"Max.Sprd.": "max_spread",
	"Min.Sprd.": "min_spread",
	"Add.Spd.": "add_spd",
}
