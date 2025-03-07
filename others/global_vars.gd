extends Node

signal score_changed(new_kills, new_loop)
signal i_see_you(isy)

func _ready() -> void:
	people = 0
	witnesses = []
	loop = 0
	kills = 0
	items = []
	money = 100
	var gun = Randogunser.get_gun()
	var t1 = load(gun.RECIEVER).duplicate()
	t1.picked_up = true
	t1.init()
	var t2 = load(gun.MAG).duplicate()
	t2.picked_up = true
	t2.init()
	var t3 = load(gun.BARREL).duplicate()
	t3.picked_up = true
	t3.init()
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
	if people == kills:
		OstManager.shift_calm()

var people = 0
var witnesses = []

func add_witness(witness):
	witnesses.append(witness)
	witnesses = array_unique(witnesses)
	if witnesses.size() != 0:
		OstManager.shift_metal()
		i_see_you.emit(true)


func erase_witness(witness):
	witnesses.erase(witness)
	if witnesses.size() == 0:
		i_see_you.emit(false)


func array_unique(array: Array) -> Array:
	var unique: Array = []
	for item in array:
		if not unique.has(item):
			unique.append(item)
	return unique

var loop = 0
var kills = 0
var items = []
var fullscreen = DisplayServer.window_get_mode()
var money = 0

var shop_items = []
