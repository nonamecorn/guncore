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
@export var authorised = false
var active = true
var known = false
var closed = false

func deactivate():
	active = false
	$Polygon2D.show()

func get_info():
	assert(authorised, "authorised access only")
	$Polygon2D2.show()
	known = true
	return {
		"type": type,
		"orientation": orientation,
		"position": global_position
	}

func close():
	if closed: return
	closed = true
	assert(authorised, "authorised access only")
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
