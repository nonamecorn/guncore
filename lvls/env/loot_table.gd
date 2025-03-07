extends StaticBody2D

@export var determined_loot : Item
@export var chance_of_drop : float = 50.0

var item_base = preload("res://obj/components/item_ground_base.tscn")
var rng = RandomNumberGenerator.new()

func init() -> void:
	rng.randomize()
	if rng.randf_range(0.0,100.0) <= chance_of_drop: return
	var item_inst = item_base.instantiate()
	get_tree().current_scene.find_child("items").call_deferred("add_child",item_inst)
	item_inst.global_position = global_position
	if determined_loot:
		item_inst.init(determined_loot)
		return
	var item_res = load(Randogunser.get_loot())
	item_inst.init(item_res)
