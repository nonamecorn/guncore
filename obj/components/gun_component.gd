extends Node2D

var facade = preload("res://obj/components/facade.tscn")
var gun_parts
var point_of_shooting = Vector2(0,0)
var spread_tween
@onready var rng = RandomNumberGenerator.new()
@export var player_handled = false
var current_ammo
var current_spread = 0

var state = STOP

enum {
	FIRE,
	STOP,
}
signal empty

var current_bullet_obj
var current_firerate
var current_max_ammo
var current_max_spread
var current_min_spread
var current_range
var current_num_of_bullets
var current_ver_recoil
var current_hor_recoil
var current_add_spd
var current_reload_time

func _ready() -> void:
	rng.randomize()

func check_point_of_fire() -> Vector2:
	return $pos.global_position

func spawn_facade(part,offset):
	var facade_inst = facade.instantiate()
	facade_inst.texture = part.sprite
	var slot = find_child(part.slot)
	slot.add_child(facade_inst)
	slot.position = offset

func dispawn_facade(part_name):
	var slot = find_child(part_name)
	if slot.get_child_count() == 0: return
	slot.get_child(0).queue_free()
	slot.position = Vector2.ZERO

func asseble_gun(parts : Dictionary):
	dissassemble_gun()
	gun_parts = parts
	spawn_facade(parts.RECIEVER, Vector2.ZERO)
	spawn_facade(parts.BARREL, parts.RECIEVER.barrel_position+parts.BARREL.sprite_offset)
	spawn_facade(parts.MAG, parts.RECIEVER.mag_position+parts.MAG.sprite_offset)
	
	current_firerate = parts.RECIEVER.base_firerate
	current_max_spread = parts.BARREL.max_spread
	current_min_spread = parts.BARREL.min_spread
	current_spread = current_min_spread
	current_range = parts.BARREL.range_in_secs
	current_max_ammo = parts.MAG.capacity
	current_ammo = parts.MAG.capacity
	current_bullet_obj = parts.MAG.projectile
	current_num_of_bullets = 1
	current_ver_recoil = parts.RECIEVER.ver_recoil
	current_hor_recoil = parts.RECIEVER.hor_recoil
	current_add_spd = parts.BARREL.add_spd
	current_reload_time = parts.MAG.reload_time
	$MUZZLE.position = parts.BARREL.muzzle_position + parts.RECIEVER.barrel_position
	$pos.position = $MUZZLE.position
	if parts.MUZZLE != null:
		spawn_facade(parts.MUZZLE, $MUZZLE.position + parts.MUZZLE.sprite_offset)
		$pos.position += parts.MUZZLE.bullet_vector
	
	for part_name in parts:
		if parts[part_name] == null: continue
		for change in parts[part_name].changes:
			if change.is_set:
				set_stat(change.stat_name, change.value_of_stat)
				continue
			change_stat(change.stat_name, change.value_of_stat, change.mult)
	$firerate.wait_time = current_firerate
	$reload.wait_time = current_reload_time
	show()
	state = FIRE

func change_stat(name_of_stat : String, value_of_stat, mult: bool):
	var temp = get(name_of_stat)
	if mult:
		set(name_of_stat, temp*value_of_stat)
		return
	set(name_of_stat, temp+value_of_stat)
func set_stat(name_of_stat : String, value_of_stat):
	set(name_of_stat, value_of_stat)


func dissassemble_gun():
	dispawn_facade("RECIEVER")
	dispawn_facade("BARREL")
	dispawn_facade("MAG")
	dispawn_facade("MUZZLE")
	hide()
	state = STOP

func start_fire():
	if state: return
	if current_ammo <= 0: return
	fire()
	if spread_tween: spread_tween.kill()
	spread_tween = create_tween()
	spread_tween.tween_property(self, "current_spread", current_max_spread, current_firerate*current_max_ammo)
	$firerate.start()

func stop_fire():
	if state: return
	if spread_tween: spread_tween.kill()
	spread_tween = create_tween()
	spread_tween.tween_property(self, "current_spread", current_min_spread, 1)
	$firerate.stop()

func _on_reload_timeout():
	current_ammo = current_max_ammo
	$MAG.show()
	state = FIRE

func reload():
	state = STOP
	$reload.start()
	$MAG.hide()
	current_spread = current_min_spread


func fire():
	if state: return
	for i in current_num_of_bullets:
		if current_ammo <= 0: 
			empty.emit()
			return
		current_ammo -= 1
		if  player_handled:
			var vievscale = get_viewport_transform().get_scale()
			var recoil_vector = Vector2(-current_ver_recoil,randf_range(-current_hor_recoil, current_hor_recoil)).rotated(global_rotation)
			Input.warp_mouse(get_viewport().get_mouse_position()*vievscale + recoil_vector*vievscale)
		var bullet_inst = current_bullet_obj.instantiate()
		bullet_inst.global_position = check_point_of_fire()
		bullet_inst.global_rotation_degrees = global_rotation_degrees + rng.randf_range(-current_spread, current_spread)
		get_tree().current_scene.call_deferred("add_child",bullet_inst) 
		bullet_inst.init(get_parent().get_parent().get_parent().velocity, current_range, current_add_spd)
