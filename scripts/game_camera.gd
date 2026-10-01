extends Camera2D
class_name GameCamera

var _shake_amp: float = 0.0
var _shake_time: float = 0.0
var _look: float = 0.0
@export var follow: NodePath
@export var look_ahead: float = 120.0
@export var bounds: Rect2 = Rect2(0, 0, 5760, 1080)


func shake(amp: float = 5.0, time: float = 0.15) -> void:
	_shake_amp = amp
	_shake_time = time


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
		_look = lerpf(_look, facing * look_ahead, 4.0 * delta)
		var desired := target.global_position + Vector2(_look, -80)
		desired.x = clampf(desired.x, bounds.position.x + 960, bounds.end.x - 960)
		desired.y = clampf(desired.y, bounds.position.y + 540, bounds.end.y - 200)
		global_position = global_position.lerp(desired, 6.0 * delta)

	if _shake_time > 0.0:
		_shake_time -= delta
		offset = Vector2(randf_range(-_shake_amp, _shake_amp), randf_range(-_shake_amp, _shake_amp))
	else:
		offset = Vector2.ZERO
