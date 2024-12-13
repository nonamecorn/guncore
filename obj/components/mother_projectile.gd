extends CharacterBody2D
class_name BasicProjectile

var spark = preload("res://obj/proj/spark.tscn")
@export var speed = 500
var move_vec : Vector2
var mod_vec : Vector2
@export var damage : int = 20
var active = true
var strategies = []
var strategy_dic = {}
var mpos = Vector2.ZERO
@export var ap : bool = false

var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	mpos = get_global_mouse_position()
	rng.randomize()
	
func init(vec: Vector2, range_sec, add_spd):
	speed+=add_spd
	mod_vec = vec
	move_vec = Vector2.RIGHT
	move_vec = move_vec.rotated(global_rotation)
	$Timer.wait_time = range_sec
	if strategies:
		for strategy in strategies:
			strategy.init_strategy(self)
	

func _physics_process(delta):
	if !active: return
	var coll = move_and_collide((move_vec * speed + mod_vec) * delta)
	if coll:
		on_collision(coll)
	if !strategies: return
	for strategy in strategies:
		strategy.move_strategy(self)

func on_collision(collider):
	if collider and collider.get_collider().has_method("hurt"):
		collider.get_collider().hurt(damage, ap)
	active = false
	$Sprite2D.hide()
	create_spark()
	queue_free()

func _on_timer_timeout():
	on_collision(null)

func create_spark():
	var spark_inst = spark.instantiate()
	spark_inst.global_position = global_position
	get_tree().current_scene.call_deferred("add_child",spark_inst)
