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

func deactivate():
	active = false

func wft():
	deactivate()
	print("wtf")
	$Polygon2D.show()

func get_info():
	return [type,orientation,global_position]

func close():
	match orientation:
		0:
			get_child(0).get_child(0).enabled = true
			get_child(0).get_child(1).enabled = true
			get_child(0).get_child(2).enabled = true
		1:
			get_child(1).get_child(0).enabled = true
		2:
			get_child(2).get_child(0).enabled = true
		3:
			get_child(3).get_child(0).enabled = true
