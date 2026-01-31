extends Node2D

class_name Gun
var modules : Array

var facade = preload("res://obj/components/facade.tscn")
var p_facade = preload("res://obj/components/p_facade.tscn")
var gun_resources
var point_of_shooting = Vector2(0,0)
var spread_tween
@onready var rng = RandomNumberGenerator.new()
@export var player_handled = false
var firing : bool
var ammo := 0
var spread := 0.0
var added_velocity : Vector2
var state = STOP
var assambled = false
@export var pitch_shifing : Curve

@export var mag : Marker2D
@export var barrel : Marker2D
@export var muzzle : Marker2D
@export var attach : Marker2D

var player_crosshair

enum {
	FIRE,
	STOP,
}
signal empty
signal ammo_changed(current,max,ind)
#signal stats_changed(stats)

#@export var muzzle_obj : PackedScene
@onready var brass_obj = preload("res://obj/components/brass.tscn")
@export var brass_texture: Texture
@export var ver_recoil: float
@export var hor_recoil: float
@export var damage: float #needs implementing

@export var default_modules : Dictionary[String,Item] = {
	"MAG": null,
	"BARREL": null,
	"MUZZLE": null,
	"ATTACH": null,
}

var max_spread: float = 1.0
var min_spread: float = 0.0
var max_ammo: int = 1
var num_of_bullets: int = 1
var bullet_obj: PackedScene

var lifetime: float = 1.0
var noise_radius: float = 500.0
var anim_firerate: float = 1.0
var anim_reload: float = 1.0
var add_spd : float
var wear : float
var weight : float

var falloff : Curve
var firing_strategies = []
var bullet_strategies = []

var silenced = false

func _ready() -> void:
	if player_handled:
		$Render.material = null
		player_crosshair = get_tree().get_nodes_in_group("crosshair")[0]
	rng.randomize()
	asseble_gun(default_modules)

func get_point_of_fire() -> Vector2:
	return $pos.global_position

func spawn_facade(part,offset):
	var facade_inst
	facade_inst = p_facade.instantiate()
	#if player_handled:
		#facade_inst = p_facade.instantiate()
	#else:
		#facade_inst = facade.instantiate()
	facade_inst.texture = part.sprite
	var slot = find_child(part.slot)
	slot.add_child(facade_inst)
	slot.position = offset
	print("huh")

func dispawn_facade(part_name : String):
	var slot = get(part_name.to_lower())
	if slot.get_child_count() == 0: return
	for child in slot.get_children():
		child.queue_free()
	slot.position = Vector2.ZERO

func asseble_gun(parts : Dictionary,loaded : bool = true):
	dissassemble_gun()
	assambled = true
	state = STOP
	gun_resources = parts
	spawn_facade(parts.BARREL, barrel.position+parts.BARREL.sprite_offset)
	spawn_facade(parts.MAG, mag.position+parts.MAG.sprite_offset)
	if parts.has("ATTACH") and parts.ATTACH:
		if parts.ATTACH.needs_facade:
			spawn_facade(parts.ATTACH, attach.position+parts.ATTACH.sprite_offset)
		else:
			var attach_inst
			attach_inst = parts.ATTACH.attach_node.instaniate()
			attach.add_child(attach_inst)

	max_spread = parts.BARREL.max_spread
	min_spread = parts.BARREL.min_spread
	spread = min_spread
	lifetime = parts.BARREL.range_in_secs
	max_ammo = parts.MAG.capacity
	bullet_obj = parts.MAG.projectile
	num_of_bullets = 1
	add_spd = parts.BARREL.add_spd
	anim_reload = parts.MAG.reload_time
	noise_radius = parts.MAG.loud_dist
	wear = parts.MAG.wear
	falloff = parts.MAG.falloff
	ammo = 0
	for part_name in parts:
		if parts[part_name] == null: continue	
		weight += parts[part_name].weight
	get_parent().get_parent().set_handling_spd(weight, get_index())
	
	#$audio/shoting.stream = parts.MAG.sound
	muzzle.position = parts.BARREL.muzzle_position + barrel.position
	$pos.position = muzzle.position + Vector2.RIGHT * 5  + Vector2(0, -0.5)
	if parts.MUZZLE != null:
		spawn_facade(parts.MUZZLE, muzzle.position + parts.MUZZLE.sprite_offset)
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
	
	var alert_shape = CircleShape2D.new()
	alert_shape.radius = noise_radius
	$noise_alert/CollisionShape2D.shape = alert_shape
	if noise_radius <= 200:
		silenced = true
		$pos/muzzleflash/light2.hide()
	else:
		silenced = false
		$pos/muzzleflash/light2.show()

	if loaded:
		_on_reload_timeout()
	else:
		reload()
	reset_spread()
	#$Sprite2D.texture = $SubViewport.get_texture()
	ammo_changed.emit(0,1,get_index())
	#stats_changed.emit(stats)


func change_stat(name_of_stat : String, value_of_stat, mult: bool):
	#var temp = get(name_of_stat)
	if !get(name_of_stat): return
	if mult:
		set(name_of_stat, get(name_of_stat) * value_of_stat)
		#set(name_of_stat, temp*value_of_stat)
		return
	#set(name_of_stat, temp+value_of_stat)
	set(name_of_stat,get(name_of_stat) + value_of_stat)


func dissassemble_gun():
	assambled = false
	stop_fire()
	mag.show()
	dispawn_facade("BARREL")
	dispawn_facade("MAG")
	dispawn_facade("MUZZLE")
	dispawn_facade("ATTACH")
	ammo = 0
	firing_strategies = []
	bullet_strategies = []
	state = STOP
	weight = 0
	display_ammo()

func reset_spread():
	spread = min_spread
	if spread_tween: spread_tween.kill()

func start_fire():
	if state: return
	if ammo <= 0:
		if player_handled: $audio/out_of_ammo.play()
		return
	$AnimationPlayer.play("fire")
	firing = true
	if spread_tween: spread_tween.kill()
	spread_tween = create_tween()
	spread_tween.tween_property(self, "spread", max_spread, anim_firerate*max_ammo)

func stop_fire():
	if state: return
	if spread_tween: spread_tween.kill()
	firing = false
	spread_tween = create_tween()
	spread_tween.tween_property(self, "spread", min_spread, anim_firerate*max_ammo)


func _on_reload_timeout():
	stop_fire()
	ammo = max_ammo
	if player_handled: $audio/reload_end_cue.play()
	mag.show()
	state = FIRE
	display_ammo()

func reload():
	if !assambled or !mag.visible or ammo == max_ammo: return
	stop_fire()
	state = STOP
	if player_handled:
		ammo = 0
		display_ammo()
		$audio/reload_start_cue.play()
	mag.hide()
	spread = min_spread
	$AnimationPlayer.play("reload")

#func wear_down():
	#for part in gun_resources:
		#if !gun_resources[part]: continue
		#gun_resources[part].curr_durability -= wear

func weapon_functional():
	for part in gun_resources:
		if !gun_resources[part]: continue
		if gun_resources[part].curr_durability <= 0:
			gun_resources[part].destry_item()
			return false
	return true

func display_ammo():
	ammo_changed.emit(ammo,max_ammo,get_index())

func get_pitch() -> float:
	if ammo <= 20:
		return pitch_shifing.sample(ammo)
	if !silenced:
		return rng.randf_range(0.9,1.1)
	else:
		return rng.randf_range(0.5,1.5)

func fire():
	if state: return
	for i in num_of_bullets:
		if ammo <= 0:
			firing = false
			empty.emit()
			return
		ammo -= 1
		display_ammo()
		#wear_down()
		
		if !silenced:
			
			$audio/shoting.pitch_scale = get_pitch()
			$audio/shoting.play()
		else:
			$audio/silenced_shooting.pitch_scale = get_pitch()
			$audio/silenced_shooting.play()
		for body in $noise_alert.get_overlapping_bodies():
				if body.has_method("alert"):
					body.alert(global_position)
		
		var bullet_inst = bullet_obj.instantiate()
		bullet_inst.global_position = get_point_of_fire()
		bullet_inst.global_rotation_degrees = global_rotation_degrees + rng.randf_range(-spread, spread)
		added_velocity = get_parent().get_parent().get_parent().velocity/2
		bullet_inst.falloff = falloff
		bullet_inst.max_range = lifetime
		for strategy in bullet_strategies:
			bullet_inst.strategies.append(strategy)
		for strategy in firing_strategies:
			strategy.apply_strategy(bullet_inst, self)
		get_tree().current_scene.call_deferred("add_child",bullet_inst)
		bullet_inst.init(added_velocity, lifetime, add_spd)
		
		var recoil_vector = Vector2(-ver_recoil,randf_range(-hor_recoil, hor_recoil))
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

func eject_brass():
	var brass_inst = brass_obj.instantiate()
	brass_inst.global_position = $ejector.global_position
	brass_inst.global_rotation = global_rotation + rng.randf_range(-PI/8, PI/8)
	brass_inst.get_child(0).texture = brass_texture
	added_velocity = get_parent().get_parent().get_parent().velocity/2
	get_tree().current_scene.find_child("ysort").call_deferred("add_child",brass_inst)
	#brass_inst.init(added_velocity, lifetime)
func eject_mag():
	var brass_inst = brass_obj.instantiate()
	brass_inst.global_position = $MAG.global_position
	brass_inst.global_rotation = global_rotation + rng.randf_range(-PI/8, PI/8) -sign(global_scale.y)*PI/2
	brass_inst.get_child(0).texture = $MAG.get_child(0).texture
	brass_inst.velocity_range = [200, 300] 
	added_velocity = get_parent().get_parent().get_parent().velocity/2
	get_tree().current_scene.find_child("ysort").call_deferred("add_child",brass_inst)
	#brass_inst.init(added_velocity, lifetime)
#func muzzle_flash():
	#var muzzle_inst = muzzle_obj.instantiate()
	#muzzle_inst.global_position = $pos.position
	#muzzle_inst.global_rotation = global_rotation
	#get_tree().current_scene.call_deferred("add_child",muzzle_inst)


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if firing and anim_name == "fire" and state == FIRE:
		$AnimationPlayer.play("fire")
	if anim_name == "reload":
		_on_reload_timeout()
		if firing:
			$AnimationPlayer.play("fire")
