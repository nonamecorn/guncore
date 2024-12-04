extends Marker2D
enum module_orientation {
	NORTH,
	WEST,
	EAST,
	SOUTH
}
enum module_type {
	CORR,
	ROOM,
}
@export var type = module_type.CORR
@export var orientation = module_orientation.NORTH
var active = true


func get_info():
	queue_free()
	return [type,orientation,global_position]

func close():
	match orientation:
		0:
			get_child(0).show()
			get_child(0).get_child(0).enabled = true
		1:
			get_child(1).show()
			get_child(1).get_child(0).enabled = true
		2:
			get_child(2).show()
			get_child(2).get_child(0).enabled = true
		3:
			get_child(3).show()
			get_child(3).get_child(0).enabled = true
