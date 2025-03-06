extends Node2D

@export var damage : float = 20.0

var item_res : Hand

signal hitted

func attack():
	$swoosh.play()
	#$AnimatedSprite2D.play()
	for body in $Area2D.get_overlapping_bodies():
		if body.has_method("hurt"):
			hitted.emit(damage/2)
			body.hurt(damage)


func throw():
	var bullet_inst = item_res.throwable.instantiate()
	bullet_inst.global_position = global_position
	bullet_inst.global_rotation_degrees = global_rotation_degrees
	get_tree().current_scene.call_deferred("add_child",bullet_inst)
	bullet_inst.linear_velocity = get_parent().get_parent().get_parent().velocity 
	bullet_inst.apply_impulse((Vector2.RIGHT * 500).rotated(global_rotation), Vector2.ZERO)

func use_hand():
	if !item_res: return
	match item_res.type:
		1:
			throw()
