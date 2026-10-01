extends Node2D
class_name IdleLife

@export var sway_deg: float = 2.0
@export var speed: float = 1.2
@export var bob: float = 0.0

var _base: Vector2
var _base_rot: float
var _phase: float


func _ready() -> void:
	_base = position
	_base_rot = rotation
	_phase = randf() * TAU


func _process(delta: float) -> void:
	_phase += delta * speed
	rotation = _base_rot + deg_to_rad(sin(_phase) * sway_deg)
	if bob != 0.0:
		position = _base + Vector2(0, sin(_phase * 1.3) * bob)
