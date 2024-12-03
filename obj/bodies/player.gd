extends  CharacterBody2D

@onready var gun = $player_hand_component
const MAX_SPEED = 160
const ACCELERATION = 1000
const FRICTION = 1000
var health = 1000
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
	$hurt_box.damaged.connect(hurt)
	$CanvasLayer/Inventory.eq_slot.assemble.connect(on_assemble)
	$CanvasLayer/Inventory.eq_slot.dissassemble.connect(on_dissassemble)

func _physics_process(delta):
	match state:
			MOVE:
				move_state(delta)
			IDLE:
				pass
			TAB_MENU:
				tab_state()

func tab_state():
	if Input.is_action_just_pressed("ui_tab"):
		$CanvasLayer.hide()
		$player_hand_component.follow = true
		$Camera2D.follow = true
		state = MOVE

func get_input_dir():
	return Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()

func move_state(delta):
	if Input.is_action_just_pressed("ui_tab"):
		$CanvasLayer.show()
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

func death():
	velocity = Vector2.ZERO
	died.emit()
	state = IDLE
	$CollisionShape2D.disabled = true

func hurt(amnt):
	health -= amnt
	print(health)
	if health == 0:
		call_deferred("death")


func on_assemble(parts):
	$player_hand_component/Marker2D/gun_base.asseble_gun(parts)

func on_dissassemble():
	$player_hand_component/Marker2D/gun_base.dissassemble_gun()
