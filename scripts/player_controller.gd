extends CharacterBody2D
class_name PlayerController

## TGYH-style free 2D walk + articulated humanoid UNIT-07 walk cycle.

const SPEED := 260.0
const ACCEL := 2400.0
const FRICTION := 2600.0
const JUMP_VELOCITY := -420.0
const COYOTE_TIME := 0.10
const JUMP_BUFFER := 0.10
const PUSH_DURATION := 0.12
const HOP_GRAVITY := 1800.0
const WALK_SWING := 42.0  # degrees — exaggerated so limbs read at camera zoom
const WALK_BOB := 5.0

@onready var sprite: Node2D = $Visual
@onready var push_area: Area2D = $PushHitbox
@onready var push_shape: CollisionShape2D = $PushHitbox/CollisionShape2D
@onready var antenna: Node2D = $Visual/Antenna
@onready var leg_l: Node2D = $Visual/Hip/LegL
@onready var leg_r: Node2D = $Visual/Hip/LegR
@onready var arm_l: Node2D = $Visual/ShoulderL
@onready var arm_r: Node2D = $Visual/ShoulderR
@onready var torso: Node2D = $Visual/Torso
@onready var head: Node2D = $Visual/Head
@onready var visual_shadow: Polygon2D = $Visual/Shadow

var facing: float = 1.0
var coyote: float = 0.0
var jump_buf: float = 0.0
var push_timer: float = 0.0
var heat_slowdown: float = 1.0
var _squash: Vector2 = Vector2.ONE
var hop_z: float = 0.0
var hop_vz: float = 0.0
var last_push_active_frames: int = 0
var _walk_phase: float = 0.0

var walk_min_y: float = 640.0
var walk_max_y: float = 980.0
var walk_min_x: float = 40.0
var walk_max_x: float = 4100.0


func _ready() -> void:
	add_to_group("player")
	motion_mode = MOTION_MODE_FLOATING
	push_area.monitoring = false
	push_shape.disabled = true
	push_area.body_entered.connect(_on_push_hit)
	push_area.area_entered.connect(_on_push_hit_area)


func set_heat_slowdown(v: float) -> void:
	heat_slowdown = v
	if antenna:
		antenna.rotation_degrees = lerp(0.0, 35.0, GameState.heat)


func set_walk_bounds(rect: Rect2) -> void:
	walk_min_x = rect.position.x
	walk_min_y = rect.position.y
	walk_max_x = rect.end.x
	walk_max_y = rect.end.y


func _physics_process(delta: float) -> void:
	var on_ground := hop_z <= 0.0
	if on_ground:
		coyote = COYOTE_TIME
		hop_z = 0.0
		hop_vz = 0.0
	else:
		coyote = maxf(coyote - delta, 0.0)
		hop_vz += HOP_GRAVITY * delta
		hop_z += hop_vz * delta
		if hop_z > 0.0:
			hop_z = 0.0
			hop_vz = 0.0
			_squash = Vector2(1.2, 0.8)
			_spawn_land_dust()

	if Input.is_action_just_pressed("jump"):
		jump_buf = JUMP_BUFFER
	else:
		jump_buf = maxf(jump_buf - delta, 0.0)

	if jump_buf > 0.0 and coyote > 0.0:
		hop_vz = JUMP_VELOCITY
		hop_z = -0.01
		jump_buf = 0.0
		coyote = 0.0
		_squash = Vector2(0.75, 1.25)

	if Input.is_action_just_released("jump") and hop_vz < 0.0:
		hop_vz *= 0.45

	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target := input * SPEED * heat_slowdown
	var moving := input.length() > 0.1
	if moving:
		if absf(input.x) > 0.1:
			facing = signf(input.x)
		velocity = velocity.move_toward(target, ACCEL * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	if Input.is_action_just_pressed("push") and push_timer <= 0.0:
		_start_push()

	if push_timer > 0.0:
		push_timer -= delta
		last_push_active_frames += 1
		if push_timer <= 0.0:
			_end_push()

	move_and_slide()

	global_position.x = clampf(global_position.x, walk_min_x, walk_max_x)
	global_position.y = clampf(global_position.y, walk_min_y, walk_max_y)

	z_index = int(global_position.y)
	var depth_t := inverse_lerp(walk_min_y, walk_max_y, global_position.y)
	var depth_s := lerpf(0.9, 1.12, clampf(depth_t, 0.0, 1.0))

	_animate_limbs(delta, moving and on_ground and push_timer <= 0.0)
	_squash = _squash.lerp(Vector2.ONE, 10.0 * delta)
	if sprite:
		var bob := sin(_walk_phase * 2.0) * WALK_BOB if moving and on_ground else 0.0
		sprite.position.y = hop_z * 0.35 + bob
		sprite.scale.y = _squash.y * depth_s * 0.85
		sprite.scale.x = absf(_squash.x) * facing * depth_s * 0.85
	# shadow squishes / slides with hop + walk so feet feel planted
	if visual_shadow:
		var hop_amt := clampf(-hop_z / 80.0, 0.0, 1.0)
		var walk_squash := 1.0 - absf(sin(_walk_phase)) * 0.12 if moving and on_ground else 1.0
		visual_shadow.scale = Vector2(
			lerpf(1.0, 0.55, hop_amt) * walk_squash,
			lerpf(1.0, 0.7, hop_amt)
		)
		visual_shadow.modulate.a = lerpf(0.22, 0.08, hop_amt)


func _animate_limbs(delta: float, walking: bool) -> void:
	if walking:
		_walk_phase += delta * 12.5 * clampf(velocity.length() / SPEED, 0.5, 1.4)
	else:
		_walk_phase = lerpf(_walk_phase, 0.0, 8.0 * delta)
	var swing := sin(_walk_phase) * WALK_SWING
	if not walking:
		swing = lerpf(swing, 0.0, 10.0 * delta)
	# slight knee foreshortening via scale — sells contact without extra bones
	var knee := absf(sin(_walk_phase))
	if leg_l:
		leg_l.rotation_degrees = swing
		leg_l.scale.y = 0.55 * (1.0 - knee * 0.12) if walking else 0.55
	if leg_r:
		leg_r.rotation_degrees = -swing
		leg_r.scale.y = 0.55 * (1.0 - (1.0 - knee) * 0.12) if walking else 0.55
	if arm_l:
		arm_l.rotation_degrees = -swing * 0.95
	if arm_r:
		arm_r.rotation_degrees = swing * 0.95
	if torso:
		torso.rotation_degrees = sin(_walk_phase) * 5.0 if walking else 0.0
		torso.position.y = -100.0 + (sin(_walk_phase * 2.0) * 2.0 if walking else 0.0)
	if head:
		head.rotation_degrees = -sin(_walk_phase) * 3.5 if walking else 0.0
		head.position.y = -148.0 + (sin(_walk_phase * 2.0) * 1.5 if walking else 0.0)


func _start_push() -> void:
	push_timer = PUSH_DURATION
	last_push_active_frames = 0
	push_area.monitoring = true
	push_shape.disabled = false
	var aim := Vector2(facing, 0)
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input.length() > 0.2:
		aim = input.normalized()
		if absf(aim.x) > 0.2:
			facing = signf(aim.x)
	push_area.position = aim * 46.0 + Vector2(0, -30)
	_squash = Vector2(1.25, 0.8)
	if arm_r:
		arm_r.rotation_degrees = 55.0 * facing
	var cam := get_viewport().get_camera_2d()
	if cam and cam.has_method("shake"):
		cam.call("shake", 2.5, 0.08)


func _spawn_land_dust() -> void:
	for i in 4:
		var d := Polygon2D.new()
		d.color = Color(0.75, 0.6, 0.4, 0.55)
		d.polygon = PackedVector2Array([
			Vector2(-4, -2), Vector2(4, -2), Vector2(3, 3), Vector2(-3, 3)
		])
		add_child(d)
		d.position = Vector2((i - 1.5) * 10.0, 2)
		var tw := create_tween()
		tw.tween_property(d, "position", d.position + Vector2((i - 1.5) * 14.0, -8), 0.2)
		tw.parallel().tween_property(d, "modulate:a", 0.0, 0.2)
		tw.tween_callback(d.queue_free)


func _end_push() -> void:
	push_area.monitoring = false
	push_shape.disabled = true


func _on_push_hit(body: Node2D) -> void:
	_try_push(body)


func _on_push_hit_area(area: Area2D) -> void:
	_try_push(area)


func _try_push(node: Node) -> void:
	var p := _find_pushable(node)
	if p:
		var dir := Vector2(facing, 0)
		var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
		if input.length() > 0.2:
			dir = input.normalized()
		p.receive_push(dir)


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


func debug_force_jump_buffer() -> void:
	jump_buf = JUMP_BUFFER


func debug_get_coyote() -> float:
	return coyote


func debug_get_jump_buf() -> float:
	return jump_buf


func debug_get_push_timer() -> float:
	return push_timer
