extends TextureRect
 
var items = []
 
var grid = {}
var cell_size = 64.0
var grid_width = 0.0
var grid_height = 0.0

const item_base = preload("res://ui/item_base.tscn")
@export var popup : Node
@export var shop_items_ctrl : Node

var current_deal = []
var current_reroll_cost
var loaded = false

func _ready():
	var s = get_grid_size(self)
	grid_width = s.x
	grid_height = s.y
 
	for x in range(grid_width):
		grid[x] = {}
		for y in range(grid_height):
			grid[x][y] = false

func reroll_shop():
	flush_shop()
	current_deal = []
	for path in Randogunser.get_shop():
		current_deal.append(path)
		add_item(path)

func add_item(path):
	if !path: return
	var item_res = load(path).duplicate()
	if !item_res: return
	item_res.from_shop = true
	var item_inst = item_base.instantiate()
	item_inst.item_resource = item_res
	item_inst.texture = item_res.sprite
	shop_items_ctrl.add_child(item_inst)
	insert_item_at_first_available_spot(item_inst)

func show_shop():
	for path in current_deal:
		add_item(path)

func load_shop():
	if !loaded:
		loaded = true
		reroll_shop()
	else:
		show_shop()

func flush_shop():
	for x in range(grid_width):
		grid[x] = {}
		for y in range(grid_height):
			grid[x][y] = false
	for child in shop_items_ctrl.get_children():
		child.queue_free()

func insert_item_iternal(item):
	var item_pos = item.global_position + Vector2(cell_size / 2, cell_size / 2)
	var g_pos = pos_to_grid_coord(item_pos)
	var item_size = get_grid_size(item)
	if is_grid_space_available(g_pos.x, g_pos.y, item_size.x, item_size.y):
		set_grid_space(g_pos.x, g_pos.y, item_size.x, item_size.y, true)
		item.global_position = global_position + Vector2(g_pos.x, g_pos.y) * cell_size
		items.append(item)
		GlobalVars.items.erase(item.item_resource)
		if !item.item_resource.from_shop:
			get_parent().sell_item()
		return true
	else:
		return false


func grab_item(pos):
	var item = get_item_under_pos(pos)
	if item == null:
		return null
 
	var item_pos = item.global_position + Vector2(cell_size / 2, cell_size / 2)
	var g_pos = pos_to_grid_coord(item_pos)
	var item_size = get_grid_size(item)
	set_grid_space(g_pos.x, g_pos.y, item_size.x, item_size.y, false)
 
	items.pop_at(items.find(item))
	return item
 
func pos_to_grid_coord(pos):
	var local_pos = pos - global_position
	var results = {}
	results.x = int(local_pos.x / cell_size)
	results.y = int(local_pos.y / cell_size)
	return results
 
func get_grid_size(item):
	var results = {}
	var s = item.size
	results.x = clamp(int(s.x / cell_size), 1, 500)
	results.y = clamp(int(s.y / cell_size), 1, 500)
	return results
 
func is_grid_space_available(x, y, w ,h):
	if x < 0 or y < 0:
		return false
	if x + w > grid_width or y + h > grid_height:
		return false
	for i in range(x, x + w):
		for j in range(y, y + h):
			if grid[i][j]:
				return false
	return true
 
func set_grid_space(x, y, w, h, state):
	for i in range(x, x + w):
		for j in range(y, y + h):
			grid[i][j] = state
 
func get_item_under_pos(pos):
	for item in items:
		if !is_instance_valid(item): continue
		if item.get_global_rect().has_point(pos):
			return item
	return null
 
func insert_item_at_first_available_spot(item):
	for y in range(grid_height):
		for x in range(grid_width):
			if !grid[x][y]:
				item.global_position = global_position + Vector2(x, y) * cell_size
				if insert_item_iternal(item):
					return true
	return false
