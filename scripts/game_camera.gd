extends Camera2D
class_name GameCamera

var _shake_amp: float = 0.0
var _shake_time: float = 0.0
var _shake_decay: float = 0.0
var _look_x: float = 0.0
var _look_y: float = 0.0
@export var follow: NodePath
@export var look_ahead: float = 120.0
@export var bounds: Rect2 = Rect2(0, 0, 5760, 1080)


func shake(amp: float = 5.0, time: float = 0.15) -> void:
	_shake_amp = maxf(_shake_amp, amp)
	_shake_time = maxf(_shake_time, time)
	_shake_decay = _shake_amp / maxf(time, 0.01)


func _process(delta: float) -> void:
	var target: Node2D = null
	if follow:
		target = get_node_or_null(follow) as Node2D
	if target == null:
		var players := get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			target = players[0] as Node2D
	if target:
		var facing := 1.0
		if "facing" in target:
			facing = target.facing
		# Horizontal look-ahead from facing; vertical bias from depth position
		_look_x = lerpf(_look_x, facing * look_ahead, 5.0 * delta)
		var depth_bias := 0.0
		if "velocity" in target:
			depth_bias = clampf(target.velocity.y * 0.08, -35.0, 35.0)
		_look_y = lerpf(_look_y, -48.0 + depth_bias, 4.0 * delta)
		var desired := target.global_position + Vector2(_look_x, _look_y)
		desired.x = clampf(desired.x, bounds.position.x + 960, bounds.end.x - 960)
		desired.y = clampf(desired.y, 460.0, 780.0)
		# Snappier when moving fast
		var speed := 0.0
		if "velocity" in target:
			speed = target.velocity.length()
		var follow_lerp := lerpf(5.5, 9.0, clampf(speed / 260.0, 0.0, 1.0))
		global_position = global_position.lerp(desired, follow_lerp * delta)

	if _shake_time > 0.0:
		_shake_time -= delta
		_shake_amp = maxf(0.0, _shake_amp - _shake_decay * delta)
		offset = Vector2(
			randf_range(-_shake_amp, _shake_amp),
			randf_range(-_shake_amp, _shake_amp)
		)
	else:
		offset = offset.lerp(Vector2.ZERO, 12.0 * delta)
		_shake_amp = 0.0
