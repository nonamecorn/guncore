extends CharacterBody2D

var spark = preload("res://obj/proj/spark.tscn")
@export var speed = 500
var move_vec : Vector2
var mod_vec : Vector2
@export var damage : int = 20
var active = true
var strategies = []
var strategy_dic = {}
@export var ap : bool = false

var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	
func init(vec: Vector2, range_sec, add_spd):
	if strategies:
		for strategy in strategies:
			strategy.init_strategy(self)
	speed+=add_spd
	mod_vec = vec
	move_vec = Vector2.RIGHT
	move_vec = move_vec.rotated(global_rotation)
	$Timer.wait_time = range_sec
	

func _physics_process(delta):
	var coll = move_and_collide((move_vec * speed + mod_vec) * delta)
	if !active: return
	if coll:
		active = false
		if coll.get_collider().has_method("hurt"):
			coll.get_collider().hurt(damage, ap)
		$Sprite2D.hide()
		create_spark()
		queue_free()
	if !strategies: return
	for strategy in strategies:
		strategy.move_strategy(self)

func _on_timer_timeout():
	$Sprite2D.hide()
	create_spark()
	queue_free()

func create_spark():
	var spark_inst = spark.instantiate()
	spark_inst.global_position = global_position
	get_tree().current_scene.call_deferred("add_child",spark_inst)
