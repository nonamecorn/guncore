extends  CharacterBody2D
#hmmm

@onready var gun = $player_hand_component
@onready var item_base = load("res://obj/components/item_ground_base.tscn")
const MAX_SPEED = 160
const ACCELERATION = 1000
const FRICTION = 1000
var health : int = 200
var flipped = false
signal died
enum {
	MOVE,
	IDLE,
	TAB_MENU
}
var state = MOVE
var tween : Tween

func _ready() -> void:
	hurt(0)
	refresh()
	$hurt_box.damaged.connect(hurt)
	$CanvasLayer/Inventory.money_changed.connect(refresh)
	$CanvasLayer/Inventory.drop.connect(drop)
	$CanvasLayer/Inventory.eq_slot1.assemble.connect(on_assemble)
	$CanvasLayer/Inventory.eq_slot1.dissassemble.connect(on_dissassemble)
	$CanvasLayer/Inventory.eq_slot2.assemble.connect(on_assemble2)
	$CanvasLayer/Inventory.eq_slot2.dissassemble.connect(on_dissassemble2)
	$CanvasLayer/Inventory.load_save()

func _physics_process(delta):
	if Input.is_action_just_pressed("special_button"):
		get_tree().reload_current_scene()
	else:
		match state:
				MOVE:
					move_state(delta)
				IDLE:
					pass
				TAB_MENU:
					tab_state()
		

func tab_state():
	if Input.is_action_just_pressed("ui_tab"):
		$CanvasLayer/Inventory.hide_properly()
		$CanvasLayer/Inventory.switch_to_inventory()
		$player_hand_component.follow = true
		$Camera2D.follow = true
		state = MOVE



func open_shop():
	$CanvasLayer/Inventory.switch_to_shop()
	get_items()
	$CanvasLayer/Inventory.show()
	$CanvasLayer/money.show()
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
		velocity = velocity.move_toward(input_vector * MAX_SPEED,delta * ACCELERATION)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, delta * FRICTION)
	move_and_slide()

func play():
	state = MOVE
	$Camera2D.enabled = true

func flip():
	flipped = !flipped
	$Sprite2D.scale.x *= -1

func refresh():
	$CanvasLayer/money.text = str(GlobalVars.money)+"$"

func death():
	velocity = Vector2.ZERO
	died.emit()
	state = IDLE
	$death.play()
	$CollisionShape2D.disabled = true
	$Sprite2D.rotation_degrees = 90

func hurt(amnt):
	health -= amnt
	$CanvasLayer/hp.text = str(health)
	if health <= 0:
		call_deferred("death")

func drop(item : Item):
	GlobalVars.items.erase(item)
	var item_inst = item_base.instantiate()
	item_inst.global_position = global_position
	get_tree().current_scene.find_child("items").call_deferred("add_child",item_inst) 
	item_inst.init(item)

func get_items():
	$CanvasLayer/Inventory.collector.flush()
	for item in $collector.get_overlapping_areas():
		$CanvasLayer/Inventory.pickup_collector(item.pickup())

func on_assemble(parts):
	$player_hand_component/Marker2D/gun_base.asseble_gun(parts)

func on_dissassemble():
	$player_hand_component/Marker2D/gun_base.dissassemble_gun()

func on_assemble2(parts):
	$player_hand_component/Marker2D/gun_base2.asseble_gun(parts)

func on_dissassemble2():
	$player_hand_component/Marker2D/gun_base2.dissassemble_gun()


func _on_collector_area_entered(_area: Area2D) -> void:
	pass
