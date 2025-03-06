extends Node2D

@export var hand_length = 34
@export var particles : Node 
@export var turn_speed = 200.0
func _ready() -> void:
	player_crosshair = get_tree().get_nodes_in_group("crosshair")[0]
	$Marker2D.position.x = hand_length
var look_vec = Vector2.ZERO
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
	if Input.is_action_just_pressed("ui_right_mouse"):
		$Marker2D/Melee_component.use_hand()
	if Input.is_action_just_pressed("q"):
		if active_base == 1:
			switch_to_base(true)
		else:
			switch_to_base(false)
	if Input.is_action_just_pressed("3"):
		$Marker2D.get_child(2).attack()
	if Input.is_action_just_pressed("ui_left_mouse"):
		$Marker2D.get_child(active_base).start_fire()
	if Input.is_action_just_released("ui_left_mouse"):
		$Marker2D.get_child(active_base).stop_fire()
	if Input.is_action_just_released("reload"):
		$Marker2D.get_child(active_base).reload()
	look_vec = get_parent().get_children()[-1].global_position - global_position
	#face_point(delta) get_global_mouse_position()
	global_rotation = atan2(look_vec.y, look_vec.x)
	if look_vec.x < 0 and !flipped:
		flip()
	if look_vec.x >= 0 and flipped:
		flip()

func face_point(delta: float):
	var direction = look_vec
	var angle = transform.x.angle_to(direction)
	rotate(sign(angle) * min(delta*deg_to_rad(turn_speed), abs(angle)))

func apply_recoil(recoil_vector):
	get_parent().get_children()[-1].apply_recoil(recoil_vector)
func set_handling_spd(weight):
	get_parent().get_children()[-1].set_handling_spd(weight)

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
