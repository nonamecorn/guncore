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
var known = false

func deactivate():
	active = false
	#$Polygon2D.show()

func get_info():
	known = true
	return [type,orientation,global_position]

func close():
	if !active: return
	match orientation:
		0:
			$NORTH.show()
			$NORTH/StaticBody2D/CollisionShape2D.disabled = false
		1:
			$WEST.show()
			$WEST/StaticBody2D/CollisionShape2D.disabled = false
		2:
			$EAST.show()
			$EAST/StaticBody2D/CollisionShape2D.disabled = false
		3:
			$SOUTH.show()
			$SOUTH/StaticBody2D/CollisionShape2D.disabled = false
