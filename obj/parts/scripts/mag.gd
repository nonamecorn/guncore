extends Item
class_name Mag


@export var capacity = 30
@export var projectile = preload("res://obj/proj/fmj.tscn")
@export var reload_time = 0
@export var sound : AudioStream
@export var loud_dist : int = 400
@export var proj_desc : String = "FMJ"
@export var wear : float = 1.0

var slot : String = "MAG"

var stats = {
	"Capacity": "capacity",
	"Alert Distance": "loud_dist",
	"Reload time": "reload_time",
	"Wear": "wear",
	"Projectile Description": "proj_desc",
}
