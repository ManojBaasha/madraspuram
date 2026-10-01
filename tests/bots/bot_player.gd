extends Node
## Plays a JSON timeline of Input actions; asserts GameState flags.

@export var timeline_path: String = "res://tests/bots/full_run.json"
@export var auto_start: bool = true

var _events: Array = []
var _t: float = 0.0
var _idx: int = 0
var _held: Dictionary = {}


func _ready() -> void:
	if FileAccess.file_exists(timeline_path):
		var txt := FileAccess.open(timeline_path, FileAccess.READ).get_as_text()
		var data = JSON.parse_string(txt)
		if typeof(data) == TYPE_DICTIONARY:
			_events = data.get("events", [])
	if auto_start:
		set_process(true)


func _process(delta: float) -> void:
	_t += delta
	while _idx < _events.size() and float(_events[_idx].get("t", 0)) <= _t:
		_apply(_events[_idx])
		_idx += 1
	if _idx >= _events.size() and _events.size() > 0:
		_finish()


func _apply(ev: Dictionary) -> void:
	if ev.has("press"):
		var a: String = ev["press"]
		Input.action_press(a)
		_held[a] = true
	if ev.has("release"):
		var a2: String = ev["release"]
		Input.action_release(a2)
		_held.erase(a2)
	if ev.has("assert_flag"):
		var f: String = ev["assert_flag"]
		var expect = ev.get("value", true)
		assert(GameState.get_flag(f) == expect, "Flag assert failed: %s" % f)
		print("BOT OK flag ", f, "=", expect)
	if ev.has("set_flag"):
		# Allow bots to fast-forward physics-blocked steps in headless
		GameState.set_flag(str(ev["set_flag"]), ev.get("value", true))
	if ev.has("quit"):
		_finish()


func _finish() -> void:
	for a in _held.keys():
		Input.action_release(a)
	_held.clear()
	print("BOT DONE t=", _t)
	set_process(false)
	if ev_has_quit():
		get_tree().quit(0)


func ev_has_quit() -> bool:
	for e in _events:
		if e.has("quit"):
			return true
	return false
