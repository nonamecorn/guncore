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



func pop():
	queue_free()
	return [type,orientation,global_position]
