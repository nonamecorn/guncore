extends Node

signal score_changed(new_kills, new_loop)

func _ready() -> void:
	loop = 0
	kills = 0
	items = []
	money = 0
	var gun = Randogunser.get_gun()
	var t1 = load(gun.RECIEVER).duplicate()
	t1.picked_up = true
	var t2 = load(gun.MAG).duplicate()
	t2.picked_up = true
	var t3 = load(gun.BARREL).duplicate()
	t3.picked_up = true
	items.append(t1)
	items.append(t2)
	items.append(t3)

func reset():
	change_score(0,0)
	items = []
	fullscreen = false
	money = 0
	_ready()


const item_base = preload("res://ui/item_base.tscn")

func change_score(new_kills, new_loop):
	kills = new_kills
	loop = new_loop
	score_changed.emit(new_kills, new_loop)

var loop = 0
var kills = 0
var items = []
var fullscreen = false
var money = 0
