extends Node
class_name HeatBody

## Diegetic heat — no UI meter. Modulates parent speed.

@export var heat_rate_sun: float = 0.12
@export var cool_rate_shade: float = 0.25

var in_sun: bool = true
var _player: Node = null


func _ready() -> void:
	_player = get_parent()


func _physics_process(delta: float) -> void:
	var h: float = GameState.heat
	if in_sun:
		h += heat_rate_sun * delta
	else:
		h -= cool_rate_shade * delta
	GameState.set_heat(h)
	if _player and _player.has_method("set_heat_slowdown"):
		_player.set_heat_slowdown(lerp(1.0, 0.55, GameState.heat))


func set_in_sun(value: bool) -> void:
	in_sun = value


func splash_cool(amount: float = 0.6) -> void:
	GameState.set_heat(GameState.heat - amount)
