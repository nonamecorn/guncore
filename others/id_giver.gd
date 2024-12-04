extends Node

var id_count = 0


func get_id() -> int:
	id_count += 1
	return id_count
