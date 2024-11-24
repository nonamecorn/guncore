extends RigidBody2D

#var spark = preload("res://obj/projs/spark.tscn")

var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	
func init(vec: Vector2):
	apply_impulse(Vector2(700,0).rotated(global_rotation + rng.randf_range(-0.02,0.02)) + vec)

func _on_body_entered(body):
	if body.has_method("hurt"):
		body.hurt(1)
#		var bullet_inst = spark.instantiate()
		#bullet_inst.global_position = global_position
		#get_tree().current_scene.add_child.call_deferred(bullet_inst)
	$Sprite2D.hide()
	$destroy_anim.show()
	$destroy_anim.play()

func _on_timer_timeout():
	$Sprite2D.hide()
	$destroy_anim.show()
	$destroy_anim.play()


func _on_destroy_anim_animation_finished() -> void:
	queue_free()
