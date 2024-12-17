extends LightOccluder2D



@export var left = false
@onready var player = get_tree().get_nodes_in_group("player")[0]
@onready var da_x = global_position.x
var active = true
var lmask


func _ready() -> void:
	lmask = occluder_light_mask

func _physics_process(_delta: float) -> void:
	if !left:
		if active and player.global_position.x > da_x:
			switch()
		elif !active and player.global_position.x < da_x:
			switch()
	else:
		if active and player.global_position.x < da_x:
			switch()
		elif !active and player.global_position.x > da_x:
			switch()

func switch() -> void:
	if active:
		#print(get_occluder_light_mask())
		set_occluder_light_mask(0)
		active = !active
	else:
		#print(get_occluder_light_mask())
		set_occluder_light_mask(2)
		active = !active
