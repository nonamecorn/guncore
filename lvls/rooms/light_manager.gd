extends Node2D

var sector = [0, PI/2*3]
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var look_vec = $Player.position - $LightOccluder2D.position
	if look_vec.angle() > 0 and look_vec.angle() < PI/2:
		$LightOccluder2D.hide()
	else:
		$LightOccluder2D.show()
	
