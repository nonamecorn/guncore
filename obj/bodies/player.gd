extends  CharacterBody2D
#hmmm

@onready var gun = $player_hand_component
@onready var item_base = load("res://obj/components/item_ground_base.tscn")

var MAX_SPEED = 200
var ACCELERATION = 1500
var FRICTION = 1500

var speed = MAX_SPEED
var acceleration = ACCELERATION
var friction = FRICTION

var health : float = 500.0
var max_health : float = 500.0
var armor : int = 0

var flipped = false
signal died
enum {
	MOVE,
	IDLE,
	TAB_MENU
}
var state = MOVE
var tween : Tween
var eq_res : Dictionary
var strategies = []
var strategy_dic = {}
var active_gun : int = 0

func _ready() -> void:
	on_score_change(GlobalVars.kills, GlobalVars.loop)
	hurt(0)
	refresh()
	if GlobalVars.loop == 0:
		on_ammo_change(null,null,0)
	$hurt_box.damaged.connect(hurt)
	$CanvasLayer/Inventory.money_changed.connect(refresh)
	$CanvasLayer/Inventory.drop.connect(drop)
	$CanvasLayer/Inventory.eq_slot1.assemble.connect(on_assemble)
	$CanvasLayer/Inventory.eq_slot1.dissassemble.connect(on_dissassemble)
	$CanvasLayer/Inventory.eq_slot2.assemble.connect(on_assemble2)
	$CanvasLayer/Inventory.eq_slot2.dissassemble.connect(on_dissassemble2)
	$CanvasLayer/Inventory.eq_slot3.change.connect(on_augs_change)
	$CanvasLayer/Inventory.load_save()
	$player_hand_component/Marker2D/Melee_component.hitted.connect(heal)
	$player_hand_component/Marker2D/gun_base.ammo_changed.connect(on_ammo_change)
	$player_hand_component/Marker2D/gun_base2.ammo_changed.connect(on_ammo_change)
	GlobalVars.score_changed.connect(on_score_change)
	GlobalVars.i_see_you.connect(on_perception_change)

func _unhandled_input(_event: InputEvent) -> void:
	pass
	#if event.is_action_pressed("ui_cancel") and state != TAB_MENU:
		#$CanvasLayer/pause.toggle_on()

func _physics_process(delta):
	if Input.is_action_just_pressed("special_button"):
		get_tree().reload_current_scene()
		return
	if Input.is_action_just_pressed("e"):
		get_item()
	match state:
			MOVE:
				move_state(delta)
			IDLE:
				pass
			TAB_MENU:
				tab_state()
	

func tab_state():
	$Sprite2D/IdleAnimation.show()
	$Sprite2D/RunninAnnimation.hide()
	if Input.is_action_just_pressed("ui_tab") or Input.is_action_just_pressed("ui_cancel"):
		$CanvasLayer/Inventory.hide_properly()
		$CanvasLayer/Inventory.switch_to_inventory()
		$player_hand_component.follow = true
		$Camera2D.follow = true
		state = MOVE



func open_shop():
	$CanvasLayer/Inventory.switch_to_shop()
	get_items()
	$CanvasLayer/Inventory.show()
	$CanvasLayer/Inventory/shop_backpack2.load_shop()
	$Camera2D.follow = false
	$player_hand_component.follow = false
	state = TAB_MENU

func get_input_dir():
	return Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()

func move_state(delta):
	if Input.is_action_just_pressed("ui_tab"):
		
		get_items()
		$CanvasLayer/Inventory.show()
		$Camera2D.follow = false
		$player_hand_component.follow = false
		state = TAB_MENU
	var input_vector = get_input_dir()
	if input_vector != Vector2.ZERO:
		$Sprite2D/IdleAnimation.hide()
		$Sprite2D/RunninAnnimation.show()
		velocity = velocity.move_toward(input_vector * speed,delta * acceleration)
	else:
		$Sprite2D/IdleAnimation.show()
		$Sprite2D/RunninAnnimation.hide()
		velocity = velocity.move_toward(Vector2.ZERO, delta * friction)
	move_and_slide()

func play():
	state = MOVE
	$Camera2D.enabled = true

func flip():
	flipped = !flipped
	$Sprite2D.scale.x *= -1

func refresh():
	$CanvasLayer/VBoxContainer/money.text = str(GlobalVars.money)+"$"

func death():
	velocity = Vector2.ZERO
	died.emit()
	state = IDLE
	$player_hand_component.follow = false
	$CanvasLayer/Inventory.hide_properly()
	$Camera2D.follow = false
	$death.play()
	$CollisionShape2D.disabled = true
	$Sprite2D.rotation_degrees = 90
	$Sprite2D/IdleAnimation.show()
	$Sprite2D/IdleAnimation.stop()
	$Sprite2D/RunninAnnimation.hide()
	$player_hand_component.hide()
	GlobalVars.kills = 0
	GlobalVars.loop = 0
	$CanvasLayer/ded_menu.show()

func heal(amnt):
	health += amnt
	health = clamp(health,0.0,max_health)
	$CanvasLayer/VBoxContainer/hp.text = str(health)
	$ProgressBar.value = health

var incoming_damage
func hurt(amnt:float):
	incoming_damage = amnt
	if strategies:
		for strategy in strategies:
			strategy.hurt_strategy(self, incoming_damage)
	health -= incoming_damage
	wear_down(incoming_damage)
	$CanvasLayer/VBoxContainer/hp.text = str(health)
	$ProgressBar.value = health
	incoming_damage = 0
	if health <= 0:
		call_deferred("death")
	for part in eq_res:
		if part == "HAND" or !eq_res.has(part) or !eq_res[part]: continue
		if !module_functional(part):
			eq_res.erase(part)
	on_augs_change(eq_res)

func wear_down(ammnt):
	for part in eq_res:
		if !eq_res[part] or part == "HAND": continue
		eq_res[part].curr_durability -= ammnt

func module_functional(modname) -> bool:
	if eq_res[modname].curr_durability <= 0:
		return false
	return true

func drop(item : Item):
	GlobalVars.items.erase(item)
	var item_inst = item_base.instantiate()
	item_inst.global_position = global_position
	get_tree().current_scene.find_child("items").call_deferred("add_child",item_inst) 
	item_inst.init(item)

func get_items():
	$CanvasLayer/Inventory.collector.flush()
	for item in $collector.get_overlapping_areas():
		var res = item.pickup()
		if res is Array:
			for sub_item in res:
				$CanvasLayer/Inventory.pickup_collector(sub_item)
			continue
		$CanvasLayer/Inventory.pickup_collector(res)

func get_item():
	if $collector.get_overlapping_areas().size() == 0:
		return
	var res = $collector.get_overlapping_areas()[0].pickup()
	if res is Array: return
	if res is Gun:
		$CanvasLayer/Inventory.pickup_gun(res)
	$CanvasLayer/Inventory.pickup_item(res)
	#if !:
		#var item_inst = item_base.instantiate()
		#item_inst.global_position = global_position
		#get_tree().current_scene.find_child("items").call_deferred("add_child",item_inst) 
		#item_inst.init(res)

func on_assemble(parts,loaded):
	$player_hand_component/Marker2D/gun_base.asseble_gun(parts,loaded)

func on_dissassemble():
	$player_hand_component/Marker2D/gun_base.dissassemble_gun()

func on_assemble2(parts,loaded):
	$player_hand_component/Marker2D/gun_base2.asseble_gun(parts,loaded)

func on_dissassemble2():
	$player_hand_component/Marker2D/gun_base2.dissassemble_gun()

func on_ammo_change(curr_mmo,max_mmo,ind):
	if $player_hand_component.active_base != ind: return
	if curr_mmo == null or max_mmo == null:
		$CanvasLayer/VBoxContainer/ammo.text = ""
		$AmmoBar.hide()
	else:
		$AmmoBar.show()
		$AmmoBar.max_value = max_mmo
		$AmmoBar.value = curr_mmo
		$CanvasLayer/VBoxContainer/ammo.text = str(curr_mmo)+"/"+str(max_mmo)

func on_augs_change(parts : Dictionary):
	if !parts: return
	remove_all_parts(parts)
	eq_res = parts
	speed = MAX_SPEED
	acceleration = ACCELERATION
	friction = FRICTION
	strategies = []
	strategy_dic = {}
	if parts.HAND != null:
		$player_hand_component/Marker2D/Melee_component.item_res = parts.HAND
	for part_name in parts:
		if parts[part_name] == null or parts[part_name].broken: continue
		for stratagy in parts[part_name].player_strategies:
			strategies.append(stratagy)
		for change in parts[part_name].changes:
			if change.is_set:
				set(change.stat_name, change.value_of_stat)
				continue
			change_stat(change.stat_name, change.value_of_stat, change.mult)
func change_stat(name_of_stat : String, value_of_stat, mult: bool):
	var temp = get(name_of_stat)
	if mult:
		set(name_of_stat, temp*value_of_stat)
		return
	set(name_of_stat, temp+value_of_stat)

func remove_all_parts(parts):
	for part_name in parts:
		if parts[part_name] == null: continue
		for strategy in parts[part_name].player_strategies:
			strategy.remove(self)

func on_perception_change(isy):
	$CanvasLayer/ISY.visible = isy

func on_score_change(new_kills, new_loop):
	if health <= 0: return
	$CanvasLayer/VBoxContainer/stats.text = "kills: " + str(new_kills) + "\nloop: " + str(new_loop)
