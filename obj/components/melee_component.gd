extends Node2D

@export var damage : float = 20.0

var item_res : Hand
var can_attack = true

signal hitted

func attack():
	if !can_attack: return
	can_attack = false
	$swoosh.play()
	$AnimatedSprite2D.play()
	for body in $Area2D.get_overlapping_bodies():
		if body.has_method("hurt"):
			hitted.emit(damage/2)
			body.hurt(damage)


func throw():
	var bullet_inst = item_res.throwable.instantiate()
	bullet_inst.global_position = global_position
	bullet_inst.global_rotation_degrees = global_rotation_degrees
	get_tree().current_scene.find_child("items").call_deferred("add_child",bullet_inst) 
	bullet_inst.linear_velocity = get_parent().get_parent().get_parent().velocity 
	bullet_inst.apply_impulse((Vector2.RIGHT * 500).rotated(global_rotation), Vector2.ZERO)

func use_hand():
	if !item_res: return
	#item_res.curr_durability -= 1
	match item_res.type:
		1:
			throw()
	print("ses")
	item_res.destry_item()
	item_res = null


func _on_animated_sprite_2d_animation_finished() -> void:
	can_attack = true
