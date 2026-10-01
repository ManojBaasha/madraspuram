extends Node

signal flag_changed(flag_name: String, value: Variant)
signal heat_changed(heat: float)
signal alias_added(alias: String)
signal quest_completed

var flags: Dictionary = {
	"auto_moved": false,
	"has_milk": false,
	"tea_done": false,
	"dog_following": false,
}

var aliases: Array[String] = []
var heat: float = 0.0
var line_boil_enabled: bool = true
var text_speed: float = 1.0


func _ready() -> void:
	pass


func set_flag(flag_name: String, value: Variant = true) -> void:
	if not flags.has(flag_name):
		push_warning("Unknown flag: %s" % flag_name)
		return
	if flags[flag_name] == value:
		return
	flags[flag_name] = value
	flag_changed.emit(flag_name, value)
	if flag_name == "tea_done" and value:
		quest_completed.emit()


func get_flag(flag_name: String) -> Variant:
	return flags.get(flag_name, false)


func add_alias(alias: String) -> void:
	if alias in aliases:
		return
	aliases.append(alias)
	alias_added.emit(alias)


func set_heat(value: float) -> void:
	heat = clampf(value, 0.0, 1.0)
	heat_changed.emit(heat)


func reset() -> void:
	for key in flags.keys():
		flags[key] = false
	aliases.clear()
	heat = 0.0
	heat_changed.emit(heat)
