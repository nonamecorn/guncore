extends Item
class_name Mag


@export var capacity = 30
@export var projectile = preload("res://obj/proj/fmj.tscn")
@export var reload_time = 0
@export var sound : AudioStream
var slot : String = "MAG"
