extends CharacterBody2D

@export var damage : int = 300
var exploded = false

func hurt(_amnt):
	if exploded: return
	exploded = true
	$explosion.explode(damage)
	$Sprite2D.hide()


func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
