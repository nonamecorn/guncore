extends CharacterBody2D

#var spark = preload("res://obj/projs/spark.tscn")
@export var speed = 500
var move_vec : Vector2
var mod_vec : Vector2
@export var damage : int = 1
var active = true

var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	
func init(vec: Vector2, range_sec):
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
			coll.get_collider().hurt(damage)
		$Sprite2D.hide()
		$destroy_anim.show()
		$destroy_anim.play()

func _on_timer_timeout():
	$Sprite2D.hide()
	$destroy_anim.show()
	$destroy_anim.play()

func _on_destroy_anim_animation_finished() -> void:
	queue_free()
