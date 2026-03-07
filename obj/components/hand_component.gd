extends Node2D

@export var hand_length = 34
@export var particles : Node 
@export var turn_speed = 200.0
@export var cursor : Node
@export var inventory : Control
func _ready() -> void:
	$Marker2D.position.x = hand_length
var look_vec = Vector2.ZERO


#@onready var active_base = get_parent().active_gun

var flipped = false

var current_gun
func _process(_delta):
	
	#if Input.is_action_just_pressed("3"):
		#$Marker2D/Melee_component.use_hand()
	#if active_base == -1:
		#return
	#if Input.is_action_just_pressed("1"):
		#switch_to_base(true)
	#if Input.is_action_just_pressed("2"):
		#switch_to_base(false)
	
	#if !follow:
		#$Marker2D.get_child(active_base).stop_fire()
		#return
	#if Input.is_action_just_pressed("q"):
		#if active_base == 1:
			#switch_to_base(true)
		#else:
			#switch_to_base(false)
	#if Input.is_action_just_pressed("ui_right_mouse"):
		#$Marker2D.get_child(2).attack()
	if !current_gun: return
	if Input.is_action_just_pressed("ui_left_mouse"):
		current_gun.start_fire()
	if Input.is_action_just_released("ui_left_mouse"):
		current_gun.stop_fire()
	if Input.is_action_just_released("reload"):
		current_gun.reload()
	look_vec = cursor.global_position - global_position
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
	cursor.apply_recoil(recoil_vector)
#func set_handling_spd(weight, ind):
	#if active_base != ind: return
	#cursor.set_handling_spd(weight)


func deactivate_gun():
	
	current_gun = null

func activate_gun(gun : Gun):
	current_gun = gun
	gun.display_ammo()
	cursor.set_handling_spd(gun.weight)
	inventory.pickup_gun(gun.item_resource)

#func switch_to_base(first):
	#if first:
		#$Marker2D.get_child(active_base).stop_fire()
		#active_base = 0
		#$Marker2D.get_child(0).show()
		#$Marker2D.get_child(1).hide()
		#$Marker2D.get_child(0).display_ammo()
		#cursor.set_handling_spd($Marker2D.get_child(0).stats.weight)
	#else:
		#$Marker2D.get_child(active_base).stop_fire()
		#active_base = 1
		#$Marker2D.get_child(0).hide()
		#$Marker2D.get_child(1).show()
		#$Marker2D.get_child(1).display_ammo()
		#cursor.set_handling_spd($Marker2D.get_child(1).stats.weight)

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
