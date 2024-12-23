extends Node2D

@onready var markers = $markers.get_children()
@onready var tilemap = $layers/Ceiling

var activated = false

func init():
	if has_node("enemies"):
		for marker in $enemies.get_children():
			marker.init()
	if has_node("corps"):
		for marker in $corps.get_children():
			marker.init()

func get_exits() -> Array:
	return markers

func get_rect() -> Rect2:
	var area_rect = Rect2(tilemap.get_used_rect())
	var start = tilemap.to_global(tilemap.map_to_local(area_rect.position))
	var end = tilemap.to_global(tilemap.map_to_local(area_rect.end))
	
	var low_x = min(start.x, end.x)
	var high_x = max(start.x, end.x)
	var low_y = min(start.y, end.y)
	var high_y = max(start.y, end.y)
	
	area_rect.position = Vector2(low_x, low_y)
	area_rect.end = Vector2(high_x, high_y)
	return area_rect

func align(aligment) ->void:
	var inv_allign
	match aligment:
		0:inv_allign = 3
		1:inv_allign = 2
		2:inv_allign = 1
		3:inv_allign = 0
	position -= markers[inv_allign].position


func _on_trigger_body_entered(body: Node2D) -> void:
	if !body.is_in_group("player"): return
	if activated: return
	activated = true
	init()
