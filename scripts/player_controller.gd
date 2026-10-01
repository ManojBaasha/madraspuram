extends CharacterBody2D
class_name PlayerController

const SPEED := 280.0
const ACCEL := 2200.0
const FRICTION := 2400.0
const JUMP_VELOCITY := -520.0
const COYOTE_TIME := 0.10
const JUMP_BUFFER := 0.10
const PUSH_DURATION := 0.12
const GRAVITY := 1600.0

@onready var sprite: Node2D = $Visual
@onready var push_area: Area2D = $PushHitbox
@onready var push_shape: CollisionShape2D = $PushHitbox/CollisionShape2D
@onready var antenna: Node2D = $Visual/Antenna

var facing: float = 1.0
var coyote: float = 0.0
var jump_buf: float = 0.0
var push_timer: float = 0.0
var heat_slowdown: float = 1.0
var _squash: Vector2 = Vector2.ONE

# Exposed for unit tests
var last_push_active_frames: int = 0


func _ready() -> void:
	add_to_group("player")
	push_area.monitoring = false
	push_shape.disabled = true
	push_area.body_entered.connect(_on_push_hit)
	push_area.area_entered.connect(_on_push_hit_area)


func set_heat_slowdown(v: float) -> void:
	heat_slowdown = v
	if antenna:
		antenna.rotation_degrees = lerp(0.0, 35.0, GameState.heat)


func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		coyote = maxf(coyote - delta, 0.0)
	else:
		coyote = COYOTE_TIME

	# Jump buffer
	if Input.is_action_just_pressed("jump"):
		jump_buf = JUMP_BUFFER
	else:
		jump_buf = maxf(jump_buf - delta, 0.0)

	if jump_buf > 0.0 and coyote > 0.0:
		velocity.y = JUMP_VELOCITY
		jump_buf = 0.0
		coyote = 0.0
		_squash = Vector2(0.75, 1.25)

	# Variable jump
	if Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= 0.45

	var input_x := Input.get_axis("move_left", "move_right")
	var target := input_x * SPEED * heat_slowdown
	if absf(input_x) > 0.1:
		facing = signf(input_x)
		velocity.x = move_toward(velocity.x, target, ACCEL * delta)
		if sprite:
			sprite.scale.x = absf(sprite.scale.x) * facing
	else:
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

	# Push
	if Input.is_action_just_pressed("push") and push_timer <= 0.0:
		_start_push()

	if push_timer > 0.0:
		push_timer -= delta
		last_push_active_frames += 1
		if push_timer <= 0.0:
			_end_push()

	move_and_slide()

	# Landing squash
	if is_on_floor() and get_last_slide_collision():
		pass
	_squash = _squash.lerp(Vector2.ONE, 10.0 * delta)
	if sprite:
		sprite.scale.y = _squash.y
		sprite.scale.x = absf(_squash.x) * facing


func _start_push() -> void:
	push_timer = PUSH_DURATION
	last_push_active_frames = 0
	push_area.monitoring = true
	push_shape.disabled = false
	push_area.position.x = 36.0 * facing
	_squash = Vector2(1.3, 0.75)
	# smear arm stretch
	if sprite and sprite.has_node("Arm"):
		sprite.get_node("Arm").scale = Vector2(1.8, 0.7)


func _end_push() -> void:
	push_area.monitoring = false
	push_shape.disabled = true
	if sprite and sprite.has_node("Arm"):
		sprite.get_node("Arm").scale = Vector2.ONE


func _on_push_hit(body: Node2D) -> void:
	_try_push(body)


func _on_push_hit_area(area: Area2D) -> void:
	_try_push(area)


func _try_push(node: Node) -> void:
	var p := _find_pushable(node)
	if p:
		p.receive_push(Vector2(facing, 0))


func _find_pushable(node: Node) -> Pushable:
	if node is Pushable:
		return node
	for c in node.get_children():
		if c is Pushable:
			return c
	if node.get_parent():
		for c in node.get_parent().get_children():
			if c is Pushable:
				return c
	return null


# --- Test helpers ---
func debug_force_jump_buffer() -> void:
	jump_buf = JUMP_BUFFER


func debug_get_coyote() -> float:
	return coyote


func debug_get_jump_buf() -> float:
	return jump_buf


func debug_get_push_timer() -> float:
	return push_timer
