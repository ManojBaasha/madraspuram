extends Node
class_name Pushable

## Attach to any Area2D/CharacterBody2D in group "pushable".

signal pushed(direction: Vector2, hit_count: int)
signal reacted(reaction: String)

@export var reaction: String = "wobble"  # wobble, squash, fall, launch, spin, custom
@export var max_hits_before_exhausted: int = 3
@export var sfx_path: String = "res://audio/sfx/push.wav"
@export var custom_id: String = ""

var hit_count: int = 0
var _visual: Node2D
var _busy: bool = false


func _ready() -> void:
	add_to_group("pushable")
	if get_parent() is Node2D:
		_visual = get_parent() as Node2D
	# Prefer Area2D host
	var host := get_parent()
	if host is Area2D:
		pass
	elif host.has_node("HitArea"):
		pass


func receive_push(direction: Vector2) -> void:
	if _busy:
		return
	hit_count += 1
	pushed.emit(direction, hit_count)
	var r := reaction
	if hit_count > max_hits_before_exhausted:
		r = "exhausted"
	reacted.emit(r)
	if ResourceLoader.exists(sfx_path):
		AudioBus.play_sfx(sfx_path, "SFX", 1.0 + randf_range(-0.05, 0.08))
	# Skip long juice in headless/bots so quest automation stays reliable
	if DisplayServer.get_name() == "headless" or OS.has_feature("movie"):
		return
	_play_juice(direction, r)


func _play_juice(direction: Vector2, r: String) -> void:
	_busy = true
	# Hit stop
	Engine.time_scale = 0.15
	await get_tree().create_timer(0.06, true, false, true).timeout
	Engine.time_scale = 1.0

	var cam := get_viewport().get_camera_2d()
	if cam and cam.has_method("shake"):
		cam.call("shake", 4.0, 0.12)

	_spawn_impact_star()

	if _visual == null:
		_busy = false
		return

	match r:
		"wobble":
			await _tween_wobble()
		"squash":
			await _tween_squash()
		"fall":
			await _tween_fall(direction)
		"launch":
			await _tween_launch(direction)
		"spin":
			await _tween_spin()
		"exhausted":
			await _tween_wobble()
		_:
			await _tween_wobble()
	_busy = false


func _spawn_impact_star() -> void:
	var star := Polygon2D.new()
	star.color = Color(1, 1, 1, 1)
	star.polygon = PackedVector2Array([
		Vector2(0, -14), Vector2(4, -4), Vector2(14, 0), Vector2(4, 4),
		Vector2(0, 14), Vector2(-4, 4), Vector2(-14, 0), Vector2(-4, -4),
	])
	var parent_n := get_parent() as Node2D
	if parent_n:
		parent_n.add_child(star)
		star.position = Vector2(0, -20)
		var tw := create_tween()
		tw.tween_property(star, "scale", Vector2(1.6, 1.6), 0.08)
		tw.tween_property(star, "modulate:a", 0.0, 0.12)
		tw.tween_callback(star.queue_free)


func _tween_wobble() -> void:
	var base := _visual.rotation
	var tw := create_tween()
	tw.tween_property(_visual, "rotation", base + 0.18, 0.05)
	tw.tween_property(_visual, "rotation", base - 0.18, 0.08)
	tw.tween_property(_visual, "rotation", base, 0.06)
	await tw.finished


func _tween_squash() -> void:
	var tw := create_tween()
	tw.tween_property(_visual, "scale", Vector2(1.25, 0.7), 0.05)
	tw.tween_property(_visual, "scale", Vector2(0.85, 1.2), 0.07)
	tw.tween_property(_visual, "scale", Vector2.ONE, 0.08)
	await tw.finished


func _tween_fall(direction: Vector2) -> void:
	var tw := create_tween()
	tw.tween_property(_visual, "rotation", 1.2 * sign(direction.x), 0.25)
	tw.parallel().tween_property(_visual, "position:y", _visual.position.y + 40, 0.25)
	await tw.finished


func _tween_launch(direction: Vector2) -> void:
	var tw := create_tween()
	var target := _visual.position + direction.normalized() * 80 + Vector2(0, -40)
	tw.tween_property(_visual, "position", target, 0.2)
	await tw.finished


func _tween_spin() -> void:
	var tw := create_tween()
	tw.tween_property(_visual, "rotation", _visual.rotation + TAU, 0.35)
	await tw.finished
