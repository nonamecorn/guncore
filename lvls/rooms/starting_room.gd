extends Node2D

@onready var tilemap = $layers/Ceiling
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

func _ready() -> void:
	var bar1 = get_node("env/explosive_barrel")
	var bar2 = get_node("env/explosive_barrel2")
	if GlobalVars.loop > 0 and bar1 and bar2:
		bar1.queue_free()
		bar2.queue_free()
