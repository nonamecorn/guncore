extends Control
 

#
# INVENTORY
#


const item_base = preload("res://ui/item_base.tscn")


@export var grid_bkpk : Node
@export var eq_slot1 : Node
@export var eq_slot2 : Node
@export var eq_slot3 : Node
@export var collector : Node
@export var safe_net : Node
@export var description : Node
@export var shop : Node
@export var shop_dil : Node
@export var desc_text : Node
@export var durabar : Node
@export var le_items : Node
@export var shop_items : Node

@export var see_stats1 : Node
@export var see_stats2 : Node
#var containers = [grid_bkpk, eq_slot1, eq_slot2, collector, augs, safe_net]

var item_held = null
var item_offset = Vector2()
var last_container = null
var last_pos = Vector2()

signal drop(item)
signal money_changed

var current_reroll_cost = 10

var default_text = "..."
var popup_items = []
func load_save():
	for le_item in GlobalVars.items:
		if !le_item.eq:
			pickup_item(le_item)
		else:
			equip_item(le_item, le_item.eq_index)
	eq_slot1.quick_reload = false
	eq_slot2.quick_reload = false

func display_desc(stats : Dictionary, first : bool):
	var formated_stats = stats.duplicate()
	formated_stats.erase("bullet_obj")
	var stat_strings = []
	for stat_name in formated_stats:
		var string = stat_name + ": " + str(formated_stats[stat_name]) + "\n"
		stat_strings.append(string)
	if first:
		see_stats1.desc_text = ""
		for stat in stat_strings:
			see_stats1.desc_text += stat
		return
	see_stats2.desc_text = ""
	for stat in stat_strings:
		see_stats2.desc_text += stat


func hide_properly():
	$shop_backpack2.flush_shop()
	hide_popup()
	hide()

func hide_popup():
	var items = le_items.get_children() + shop_items.get_children()
	for c in items:
		c._on_mouse_exited()

func switch_to_shop():
	default_text = shop_dil.default_text
	safe_net.show()
	shop.show()
	shop_dil.show()
	$reroll_button.show()

func switch_to_inventory():
	default_text = "..."
	safe_net.hide()
	shop.hide()
	shop_dil.hide()
	$reroll_button.hide()

func _input(event):
	if !visible:
		return
	if event is InputEventMouseButton and event.is_pressed():
		if event.double_click:
			#print("sda")
			quick_grab(get_global_mouse_position())

func _physics_process(_delta):
	if !visible: 
		return
	var cursor_pos = get_global_mouse_position()
	if Input.is_action_just_pressed("quick_sell"):
		quick_sell(cursor_pos)
	if Input.is_action_just_pressed("quick_grab"):
		quick_grab(cursor_pos)
	elif Input.is_action_just_pressed("ui_left_mouse"):
		grab(cursor_pos)
	elif Input.is_action_just_released("ui_left_mouse"):
		release(cursor_pos)
	if item_held != null:
		item_held.global_position = cursor_pos - item_held.get_global_rect().size/2 #+ item_offset
	check_popup(cursor_pos)

func quick_grab(cursor_pos):
	var c = get_container_under_cursor(cursor_pos)
	if c != null and c.has_method("grab_item"):
		item_held = c.grab_item(cursor_pos)
		if item_held != null:
			$audio/grab.play()
			last_container = c
			last_pos = item_held.global_position
			item_offset = item_held.global_position - cursor_pos
			if c.name == "grid_backpack":
				for i in $equipments.get_child_count():
					if $equipments.get_child(i).insert_item_at_spot(
						item_held,item_held.item_resource.slot):
						item_held = null
						return
				return_item()
			else:
				if grid_bkpk.insert_item_at_first_available_spot(item_held):
					item_held = null
				else:
					return_item()

func quick_sell(cursor_pos):
	var c = get_container_under_cursor(cursor_pos)
	if c != null and c.has_method("grab_item"):
		item_held = c.grab_item(cursor_pos)
		if item_held != null:
			$audio/grab.play()
			last_container = c
			last_pos = item_held.global_position
			item_offset = item_held.global_position - cursor_pos
			if !shop.visible or !shop.insert_item(item_held):
				return_item()
 
func grab(cursor_pos):
	var c = get_container_under_cursor(cursor_pos)
	if c != null and c.has_method("grab_item"):
		item_held = c.grab_item(cursor_pos)
		if item_held != null:
			$audio/grab.play()
			last_container = c
			last_pos = item_held.global_position
			item_offset = item_held.global_position - cursor_pos
 
func release(cursor_pos):
	if item_held == null:
		return
	var c = get_container_under_cursor(cursor_pos)
	if c == null:
		drop_item()
	elif c.has_method("occupied") and c.occupied(item_held):
		swap(c, cursor_pos)
	elif c.has_method("insert_item"):
		if c.insert_item(item_held):
			$audio/release.play()
			item_held = null
		else:
			return_item()
	else:
		return_item()

func swap(c2, cursor_pos):
	var temp_item_held = c2.grab_item(cursor_pos)
	if temp_item_held == null: 
		return_item()
		return
	var temp_last_pos = temp_item_held.global_position
	if c2.insert_item(item_held):
		$audio/release.play()
		item_held.item_resource.pick_up()
		if last_container.name == "grid_backpack" or last_container.name == "collector" or last_container.name == "shop_backpack2":
			if !grid_bkpk.insert_item_at_first_available_spot(temp_item_held):
				if last_container.name == "shop_backpack2":
					item_held = temp_item_held
					shop.insert_item_at_first_available_spot(temp_item_held)
					item_held = null
					return
				item_held = temp_item_held
				drop_item()
				return
			item_held = null
		else:
			for i in $equipments.get_child_count() - 1:
				if $equipments.get_child(i).insert_item_at_spot(
					temp_item_held,temp_item_held.item_resource.slot):
					item_held = null
					return
			return_item()
	else:
		temp_item_held.global_position = temp_last_pos
		c2.insert_item(temp_item_held)
		return_item()

func check_popup(cursor_pos):
	popup_items = le_items.get_children() + shop_items.get_children() + [see_stats1, see_stats2]
	if item_held != null:
		pass
	for c in popup_items:
		if c.get_global_rect().has_point(cursor_pos):
			desc_text.text = c.desc_text
			if "item_resource" in c:
				durabar.value = c.item_resource.curr_durability
				durabar.max_value = c.item_resource.max_durability
				durabar.show()
			break
		else:
			desc_text.text = default_text
			durabar.hide()
			#c._on_mouse_exited()

func get_container_under_cursor(cursor_pos):
	var active_containers = [grid_bkpk,
	 eq_slot1, eq_slot2,
	 collector, eq_slot3, shop,description,
	 safe_net].filter(func(thing): return thing.visible)
	for c in active_containers:
		if c.get_global_rect().has_point(cursor_pos):
			return c
	return null
 
func drop_item():
	item_held.item_resource.pickup.emit()
	drop.emit(item_held.item_resource)
	item_held.queue_free()
	item_held = null

func drop_resource(res):
	res.pickup.emit()
	drop.emit(res)


func return_item():
	item_held.global_position = last_pos
	if last_container.has_method("insert_item_iternal"):
		last_container.insert_item_iternal(item_held)
	elif last_container.has_method("insert_item"):
		last_container.insert_item(item_held)
	else:
		drop_item()
	item_held = null
	

func buy_item():
	if !item_held: return
	item_held.item_resource.from_shop = false
	item_held.reparent(le_items)
	var cost = item_held.item_resource.cost
	$audio/buy.play()
	GlobalVars.money -= cost
	money_changed.emit()

func sell_item():
	if !item_held: return
	item_held.item_resource.from_shop = true
	item_held.reparent(shop_items)
	item_held.item_resource.picked_up = false
	var cost = item_held.item_resource.cost
	GlobalVars.money += cost/2
	$audio/buy.play()
	money_changed.emit()

func unbuy_item():
	if !item_held: return
	item_held.item_resource.from_shop = true
	item_held.reparent(shop_items)
	item_held.item_resource.picked_up = false
	var cost = item_held.item_resource.cost
	GlobalVars.money += cost
	money_changed.emit()

func equip_item(item_res : Item, ind : int) -> bool:
	var item = item_base.instantiate()
	item.item_resource = item_res
	item.texture = item_res.sprite
	le_items.add_child(item)
	if !$equipments.get_child(ind).insert_item_at_spot(item, item_res.slot):
		item.queue_free()
		return false
	return true

func pickup_item(item_res : Item):
	var item = item_base.instantiate()
	item.item_resource = item_res
	item.texture = item_res.sprite
	le_items.add_child(item)
	if !grid_bkpk.insert_item_at_first_available_spot(item):
		drop_resource(item_res)
		item.queue_free()
		return false
	$audio/grab.play()
	return true

func pickup_collector(item_res : Item):
	var item = item_base.instantiate()
	item.item_resource = item_res
	item.texture = item_res.sprite
	le_items.add_child(item)
	if !collector.insert_item_at_first_available_spot(item):
		item.queue_free()
		return false
	return true





func _on_link_button_pressed() -> void:
	if  GlobalVars.money >= current_reroll_cost:
		$audio/buy.play()
		shop.reroll_shop()
		GlobalVars.money -= current_reroll_cost
		current_reroll_cost += 3
		$reroll_button/MarginContainer/LinkButton.text = "Reroll " + str(current_reroll_cost) + "$"
		money_changed.emit()




func _on_gun_base_2_stats_changed(stats: Variant) -> void:
	display_desc(stats, false)
func _on_gun_base_stats_changed(stats: Variant) -> void:
	display_desc(stats, true)
