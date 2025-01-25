extends Node2D

@export var hand_length = 34
@export var particles : Node 
func _ready() -> void:
	player_crosshair = get_tree().get_nodes_in_group("crosshair")[0]
	$Marker2D.position.x = hand_length

var player_crosshair

var active_base = 0

var flipped = false
var follow = true
func _physics_process(_delta):
	if !follow:
		$Marker2D.get_child(active_base).stop_fire()
		return
	if Input.is_action_just_pressed("1"):
		switch_to_base(true)
	if Input.is_action_just_pressed("2"):
		switch_to_base(false)
	if Input.is_action_just_pressed("e"):
		if active_base == 1:
			switch_to_base(true)
		else:
			switch_to_base(false)

	if Input.is_action_just_pressed("ui_left_mouse"):
		$Marker2D.get_child(active_base).start_fire()
	if Input.is_action_just_released("ui_left_mouse"):
		$Marker2D.get_child(active_base).stop_fire()
	if Input.is_action_just_released("reload"):
		$Marker2D.get_child(active_base).reload()
	var look_vec = get_global_mouse_position() - global_position
	global_rotation = atan2(look_vec.y, look_vec.x)
	if look_vec.x < 0 and !flipped:
		flip()
	if look_vec.x >= 0 and flipped:
		flip()

func switch_to_base(first):
	if first:
		$Marker2D.get_child(active_base).stop_fire()
		active_base = 0
		$Marker2D/gun_base.show()
		$Marker2D/gun_base2.hide()
		$Marker2D/gun_base.display_ammo()
	else:
		$Marker2D.get_child(active_base).stop_fire()
		active_base = 1
		$Marker2D/gun_base.hide()
		$Marker2D/gun_base2.show()
		$Marker2D/gun_base2.display_ammo()

func flip():
	get_parent().flip()
	flipped = !flipped
	scale.y *= -1

func add_gun(_gun):
	pass

func del_gun():
	pass

func switch_gun(gun):
	return gun
