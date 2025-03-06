extends Node2D

@export var damage : float = 20.0

signal hitted

func attack():
	$swoosh.play()
	#$AnimatedSprite2D.play()
	for body in $Area2D.get_overlapping_bodies():
		if body.has_method("hurt"):
			hitted.emit(damage/2)
			body.hurt(damage)
