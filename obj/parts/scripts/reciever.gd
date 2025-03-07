extends Item
class_name GunReciever
@export var base_firerate = 0.1
@export var ver_recoil = 0.0
@export var hor_recoil = 0.0
@export var mag_position : Vector2
@export var barrel_position : Vector2
@export var attach_position : Vector2 = Vector2.ZERO

func _init():
	slot = "RECIEVER"

var stats = {
	"Firerate": "base_firerate",
	"Ver.Rec.": "ver_recoil",
	"Hor.Rec.": "hor_recoil",
}
