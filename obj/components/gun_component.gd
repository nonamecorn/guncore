extends Node2D

var facade = preload("res://obj/components/facade.tscn")
var p_facade = preload("res://obj/components/p_facade.tscn")
var gun_resources
var point_of_shooting = Vector2(0,0)
var spread_tween
@onready var rng = RandomNumberGenerator.new()
@export var player_handled = false
var ammo
var spread = 0
var added_velocity : Vector2
var state = STOP
var gpuparticles
var assambled = false
@export var pitch_shifing : Curve

var player_crosshair

enum {
	FIRE,
	STOP,
}
signal empty
signal ammo_changed(current,max,ind)
signal stats_changed(stats)

var stats = {
	"bullet_obj": null,
	"firerate": null,
	"max_ammo": null,
	"max_spread": null,
	"min_spread": null,
	"range": null,
	"num_of_bullets": null,
	"ver_recoil": null,
	"hor_recoil": null,
	"add_spd": null,
	"reload_time": null,
	"alert_distance": null,
	"wear": null,
	"weight": null,
}
var falloff : Curve
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

func asseble_gun(parts : Dictionary,loaded : bool):
	dissassemble_gun()
	assambled = true
	state = STOP
	gun_resources = parts
	spawn_facade(parts.RECIEVER, Vector2.ZERO)
	spawn_facade(parts.BARREL, parts.RECIEVER.barrel_position+parts.BARREL.sprite_offset)
	spawn_facade(parts.MAG, parts.RECIEVER.mag_position+parts.MAG.sprite_offset)
	if parts.has("ATTACH") and parts.ATTACH:
		spawn_facade(parts.ATTACH, parts.RECIEVER.attach_position+parts.ATTACH.sprite_offset)
	
	stats.firerate = parts.RECIEVER.base_firerate
	stats.max_spread = parts.BARREL.max_spread
	stats.min_spread = parts.BARREL.min_spread
	stats.spread = stats.min_spread
	stats.range = parts.BARREL.range_in_secs
	stats.max_ammo = parts.MAG.capacity
	stats.bullet_obj = parts.MAG.projectile
	stats.num_of_bullets = 1
	stats.ver_recoil = parts.RECIEVER.ver_recoil
	stats.hor_recoil = parts.RECIEVER.hor_recoil
	stats.add_spd = parts.BARREL.add_spd
	stats.reload_time = parts.MAG.reload_time
	stats.alert_distance = parts.MAG.loud_dist
	stats.wear = parts.MAG.wear
	falloff = parts.MAG.falloff
	ammo = 0
	for part_name in parts:
		if parts[part_name] == null: continue	
		stats.weight += parts[part_name].weight
	get_parent().get_parent().set_handling_spd(stats.weight)
	
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
	
	if stats.firerate != 0:
		$firerate.wait_time = stats.firerate
	$reload.wait_time = stats.reload_time
	var alert_shape = CircleShape2D.new()
	alert_shape.radius = stats.alert_distance
	$noise_alert/CollisionShape2D.shape = alert_shape
	if stats.alert_distance <= 200:
		silenced = true
		$pos/muzzleflash/light2.hide()
	else:
		silenced = false
		$pos/muzzleflash/light2.show()
	gpuparticles = get_parent().get_parent().particles
	gpuparticles.global_position = $MAG.global_position + Vector2(0,-3)
	if stats.firerate == 0:
		gpuparticles.one_shot = true
		gpuparticles.amount = 18
	else:
		gpuparticles.one_shot = false
		gpuparticles.amount = int(1.8 / stats.firerate)
	if loaded:
		_on_reload_timeout()
	else:
		reload()
	reset_spread()
	ammo_changed.emit(0,1,get_index())
	stats_changed.emit(stats)


func change_stat(name_of_stat : String, value_of_stat, mult: bool):
	#var temp = get(name_of_stat)
	if mult:
		stats[name_of_stat] *= value_of_stat
		#set(name_of_stat, temp*value_of_stat)
		return
	#set(name_of_stat, temp+value_of_stat)
	stats[name_of_stat] += value_of_stat


func dissassemble_gun():
	assambled = false
	stop_fire()
	$reload.stop()
	$MAG.show()
	dispawn_facade("RECIEVER")
	dispawn_facade("BARREL")
	dispawn_facade("MAG")
	dispawn_facade("MUZZLE")
	dispawn_facade("ATTACH")
	ammo = null
	firing_strategies = []
	bullet_strategies = []
	state = STOP
	stats.weight = 0
	display_ammo()

func reset_spread():
	spread = stats.min_spread
	if spread_tween: spread_tween.kill()

func start_fire():
	if state: return
	if ammo <= 0:
		if player_handled: $audio/out_of_ammo.play()
		return
	fire()
	if spread_tween: spread_tween.kill()
	spread_tween = create_tween()
	spread_tween.tween_property(self, "spread", stats.max_spread, stats.firerate*stats.max_ammo)
	if stats.firerate == 0:
		gpuparticles.emitting = true
		$single_shot.start()
		return
	gpuparticles.emitting = true
	$firerate.start()

func stop_fire():
	if state: return
	if spread_tween: spread_tween.kill()
	spread_tween = create_tween()
	spread_tween.tween_property(self, "spread", stats.min_spread, stats.firerate*stats.max_ammo)
	gpuparticles.emitting = false
	$firerate.stop()

func _on_reload_timeout():
	stop_fire()
	ammo = stats.max_ammo
	if player_handled: $audio/reload_end_cue.play()
	$MAG.show()
	state = FIRE
	display_ammo()

func reload():
	if !assambled or !$MAG.visible or ammo == stats.max_ammo: return
	stop_fire()
	state = STOP
	if player_handled:
		ammo = 0
		display_ammo()
		$audio/reload_start_cue.play()
	$reload.start()
	$MAG.hide()
	spread = stats.min_spread

func wear_down():
	for part in gun_resources:
		if !gun_resources[part]: continue
		gun_resources[part].curr_durability -= stats.wear

func weapon_functional():
	for part in gun_resources:
		if !gun_resources[part]: continue
		if gun_resources[part].curr_durability <= 0:
			gun_resources[part].destry_item()
			return false
	return true

func display_ammo():
	ammo_changed.emit(ammo,stats.max_ammo,get_index())

func get_pitch() -> float:
	if ammo <= 20:
		return pitch_shifing.sample(ammo)
	if !silenced:
		return rng.randf_range(0.9,1.1)
	else:
		return rng.randf_range(0.5,1.5)

func fire():
	if state: return
	for i in stats.num_of_bullets:
		if ammo <= 0:
			gpuparticles.emitting = false
			empty.emit()
			return
		ammo -= 1
		display_ammo()
		wear_down()
		
		if !silenced:
			$AnimationPlayer.play("fire")
			$audio/shoting.pitch_scale = get_pitch()
			$audio/shoting.play()
		else:
			$audio/silenced_shooting.pitch_scale = get_pitch()
			$audio/silenced_shooting.play()
		for body in $noise_alert.get_overlapping_bodies():
				if body.has_method("alert"):
					body.alert(global_position)
		
		var bullet_inst = stats.bullet_obj.instantiate()
		bullet_inst.global_position = get_point_of_fire()
		bullet_inst.global_rotation_degrees = global_rotation_degrees + rng.randf_range(-spread, spread)
		added_velocity = get_parent().get_parent().get_parent().velocity/2
		bullet_inst.falloff = falloff
		bullet_inst.max_range = stats.range
		for strategy in bullet_strategies:
			bullet_inst.strategies.append(strategy)
		for strategy in firing_strategies:
			strategy.apply_strategy(bullet_inst, self)
		get_tree().current_scene.call_deferred("add_child",bullet_inst)
		bullet_inst.init(added_velocity, stats.range, stats.add_spd)
		
		var recoil_vector = Vector2(-stats.ver_recoil,randf_range(-stats.hor_recoil, stats.hor_recoil))
		get_parent().get_parent().apply_recoil(recoil_vector)
		#if player_handled:
			#player_crosshair.global_position += recoil_vector
			#var viewscale = get_viewport_transform().get_scale()/2
			#Input.warp_mouse(get_viewport().get_mouse_position()*viewscale + recoil_vector*viewscale)
		#else:
			#get_parent().get_parent().apply_recoil(recoil_vector)
	if !weapon_functional():
		dissassemble_gun()
		$audio/something_broke.play()
		display_ammo()
		stop_fire()


func _on_single_shot_timeout() -> void:
	gpuparticles.emitting = false
