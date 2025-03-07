extends Item
class_name Mag


@export var capacity = 30
@export var projectile = preload("res://obj/proj/fmj.tscn")
@export var reload_time = 0
@export var sound : AudioStream
@export var loud_dist : int = 400
@export var proj_desc : String = "FMJ"
@export var wear : float = 1.0
@export var falloff : Curve

func _init():
	slot = "MAG"

var stats = {
	"Capacity": "capacity",
	"Alrt.Dist.": "loud_dist",
	"Reld.time": "reload_time",
	"Wear": "wear",
	"Proj.Desc.": "proj_desc",
}
