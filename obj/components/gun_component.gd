extends Node2D

var facade = preload("res://obj/components/facade.tscn")
var p_facade = preload("res://obj/components/p_facade.tscn")
var gun_resources
var point_of_shooting = Vector2(0,0)
var spread_tween
@onready var rng = RandomNumberGenerator.new()
@export var player_handled = false
var current_ammo
var current_spread = 0
var added_velocity : Vector2
var state = STOP
var gpuparticles

var player_crosshair

enum {
	FIRE,
	STOP,
}
signal empty
signal ammo_changed(current,max,ind)

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
var alert_distance
var wear : float
var weight
var firing_strategies = []
var bullet_strategies = []

var silenced = false

func _ready() -> void:
	if player_handled:
		player_crosshair = get_tree().get_nodes_in_group("crosshair")[0]
	rng.randomize()

func get_point_of_fire() -> Vector2:
	return $pos.global_position

func spawn_facade(part,offset):
	var facade_inst
	if player_handled:
		facade_inst = p_facade.instantiate()
	else:
		facade_inst = facade.instantiate()
	facade_inst.texture = part.sprite
	var slot = find_child(part.slot)
	slot.add_child(facade_inst)
	slot.position = offset

func dispawn_facade(part_name):
	var slot = find_child(part_name)
	if slot.get_child_count() == 0: return
	for child in slot.get_children():
		child.queue_free()
	slot.position = Vector2.ZERO

func asseble_gun(parts : Dictionary):
	dissassemble_gun()
	gun_resources = parts
	spawn_facade(parts.RECIEVER, Vector2.ZERO)
	spawn_facade(parts.BARREL, parts.RECIEVER.barrel_position+parts.BARREL.sprite_offset)
	spawn_facade(parts.MAG, parts.RECIEVER.mag_position+parts.MAG.sprite_offset)
	if parts.has("ATTACH") and parts.ATTACH:
		spawn_facade(parts.ATTACH, parts.RECIEVER.attach_position+parts.ATTACH.sprite_offset)
	
	current_firerate = parts.RECIEVER.base_firerate
	current_max_spread = parts.BARREL.max_spread
	current_min_spread = parts.BARREL.min_spread
	current_spread = current_min_spread
	current_range = parts.BARREL.range_in_secs
	current_max_ammo = parts.MAG.capacity
	current_ammo = 0
	current_bullet_obj = parts.MAG.projectile
	current_num_of_bullets = 1
	current_ver_recoil = parts.RECIEVER.ver_recoil
	current_hor_recoil = parts.RECIEVER.hor_recoil
	current_add_spd = parts.BARREL.add_spd
	current_reload_time = parts.MAG.reload_time
	alert_distance = parts.MAG.loud_dist
	wear = parts.MAG.wear
	
	for part_name in parts:
		if parts[part_name] == null: continue	
		weight += parts[part_name].weight
	get_parent().get_parent().set_handling_spd(weight)
	
	$audio/shoting.stream = parts.MAG.sound
	$MUZZLE.position = parts.BARREL.muzzle_position + parts.RECIEVER.barrel_position
	$pos.position = $MUZZLE.position + Vector2.RIGHT * 5  + Vector2(0, -0.5)
	if parts.MUZZLE != null:
		spawn_facade(parts.MUZZLE, $MUZZLE.position + parts.MUZZLE.sprite_offset)
		$pos.position += parts.MUZZLE.bullet_vector
	
	for part_name in parts:
		if parts[part_name] == null: continue
		for change in parts[part_name].changes:
			if change.is_set:
				set(change.stat_name, change.value_of_stat)
				continue
			change_stat(change.stat_name, change.value_of_stat, change.mult)
		
		for stratagy in parts[part_name].bullet_strategies:
			bullet_strategies.append(stratagy)
		for stratagy in parts[part_name].shootin_strategies:
			firing_strategies.append(stratagy)
	
	if current_firerate != 0:
		$firerate.wait_time = current_firerate
	$reload.wait_time = current_reload_time
	var alert_shape = CircleShape2D.new()
	alert_shape.radius = alert_distance
	$noise_alert/CollisionShape2D.shape = alert_shape
	if alert_distance <= 200:
		silenced = true
		$pos/muzzleflash/light2.hide()
	else:
		silenced = false
		$pos/muzzleflash/light2.show()
	gpuparticles = get_parent().get_parent().particles
	gpuparticles.global_position = $MAG.global_position + Vector2(0,-3)
	if current_firerate == 0:
		gpuparticles.one_shot = true
		gpuparticles.amount = 18
	else:
		gpuparticles.one_shot = false
		gpuparticles.amount = int(1.8 / current_firerate)
	display_ammo()
	if player_handled:
		reload()
	else:
		current_ammo = current_max_ammo
		state = FIRE


func change_stat(name_of_stat : String, value_of_stat, mult: bool):
	var temp = get(name_of_stat)
	if mult:
		set(name_of_stat, temp*value_of_stat)
		return
	set(name_of_stat, temp+value_of_stat)


func dissassemble_gun():
	dispawn_facade("RECIEVER")
	dispawn_facade("BARREL")
	dispawn_facade("MAG")
	dispawn_facade("MUZZLE")
	dispawn_facade("ATTACH")
	firing_strategies = []
	bullet_strategies = []
	state = STOP
	weight = 0

func start_fire():
	if state: return
	if current_ammo <= 0: return
	fire()
	if spread_tween: spread_tween.kill()
	spread_tween = create_tween()
	spread_tween.tween_property(self, "current_spread", current_max_spread, current_firerate*current_max_ammo)
	if current_firerate == 0:
		gpuparticles.emitting = true
		$single_shot.start()
		return
	gpuparticles.emitting = true
	$firerate.start()

func stop_fire():
	if state: return
	if spread_tween: spread_tween.kill()
	spread_tween = create_tween()
	spread_tween.tween_property(self, "current_spread", current_min_spread, current_firerate*current_max_ammo)
	gpuparticles.emitting = false
	$firerate.stop()

func _on_reload_timeout():
	stop_fire()
	current_ammo = current_max_ammo
	display_ammo()
	if player_handled: $audio/reload_end_cue.play()
	$MAG.show()
	state = FIRE

func reload():
	if !$MAG.visible or current_ammo == current_max_ammo: return
	stop_fire()
	state = STOP
	if player_handled:
		current_ammo = 0
		display_ammo()
		$audio/reload_start_cue.play()
	$reload.start()
	$MAG.hide()
	current_spread = current_min_spread

func wear_down():
	for part in gun_resources:
		if !gun_resources[part]: continue
		gun_resources[part].curr_durability -= wear

func weapon_functional():
	for part in gun_resources:
		if !gun_resources[part]: continue
		if gun_resources[part].curr_durability <= 0:
			return false
	return true

func display_ammo():
	ammo_changed.emit(current_ammo,current_max_ammo,get_index())

func fire():
	if state: return
	for i in current_num_of_bullets:
		if current_ammo <= 0: 
			gpuparticles.emitting = false
			empty.emit()
			return
		current_ammo -= 1
		display_ammo()
		wear_down()
		
		if !silenced:
			$AnimationPlayer.play("fire")
			$audio/shoting.pitch_scale = rng.randf_range(0.9,1.1)
			$audio/shoting.play()
		else:
			$audio/silenced_shooting.pitch_scale = rng.randf_range(0.5,1.5)
			$audio/silenced_shooting.play()
		for body in $noise_alert.get_overlapping_bodies():
				if body.has_method("alert"):
					body.alert(global_position)
		
		var bullet_inst = current_bullet_obj.instantiate()
		bullet_inst.global_position = get_point_of_fire()
		bullet_inst.global_rotation_degrees = global_rotation_degrees + rng.randf_range(-current_spread, current_spread)
		added_velocity = get_parent().get_parent().get_parent().velocity/2
		
		for strategy in bullet_strategies:
			bullet_inst.strategies.append(strategy)
		for strategy in firing_strategies:
			strategy.apply_strategy(bullet_inst, self)
		get_tree().current_scene.call_deferred("add_child",bullet_inst)
		bullet_inst.init(added_velocity, current_range, current_add_spd)
		
		var recoil_vector = Vector2(-current_ver_recoil,randf_range(-current_hor_recoil, current_hor_recoil))
		get_parent().get_parent().apply_recoil(recoil_vector)
		#if player_handled:
			#player_crosshair.global_position += recoil_vector
			#var viewscale = get_viewport_transform().get_scale()/2
			#Input.warp_mouse(get_viewport().get_mouse_position()*viewscale + recoil_vector*viewscale)
		#else:
			#get_parent().get_parent().apply_recoil(recoil_vector)
	if !weapon_functional():
		current_ammo = 0
		display_ammo()


func _on_single_shot_timeout() -> void:
	gpuparticles.emitting = false
