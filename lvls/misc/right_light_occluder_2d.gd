extends LightOccluder2D



@export var left = false
@onready var player = get_tree().get_nodes_in_group("player")[0]
var angle : float

func _physics_process(_delta: float) -> void:
	angle = (player.global_position - global_position).angle()
	if tan(angle) <= 0 and left:
		switch(true)
		return
	if tan(angle) > 0 and !left:
		switch(true)
		return
	switch(false)

func switch(a : bool) -> void:
	set_occluder_light_mask(int(a))
