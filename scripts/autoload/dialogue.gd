extends Node

signal line_spoken(npc_id: String, line: Dictionary)

var _data: Dictionary = {}
var _path := "res://data/dialogue.json"


func _ready() -> void:
	reload()


func reload() -> void:
	if not FileAccess.file_exists(_path):
		_data = {"npcs": {}}
		return
	var file := FileAccess.open(_path, FileAccess.READ)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		_data = parsed
	else:
		_data = {"npcs": {}}


func get_line(npc_id: String, key: String) -> Dictionary:
	var npcs: Dictionary = _data.get("npcs", {})
	var npc: Dictionary = npcs.get(npc_id, {})
	var lines: Dictionary = npc.get("lines", {})
	var line: Variant = lines.get(key, null)
	if typeof(line) == TYPE_DICTIONARY:
		return line
	return {
		"ta": "...",
		"en_subtitle": "...",
		"confidence": "low",
	}


func pick_line_for_flags(npc_id: String) -> Dictionary:
	var npcs: Dictionary = _data.get("npcs", {})
	var npc: Dictionary = npcs.get(npc_id, {})
	var rules: Array = npc.get("flag_rules", [])
	for rule in rules:
		var need: Dictionary = rule.get("when", {})
		var ok := true
		for flag_name in need.keys():
			if GameState.get_flag(flag_name) != need[flag_name]:
				ok = false
				break
		if ok:
			return get_line(npc_id, rule.get("line", "default"))
	return get_line(npc_id, npc.get("default", "default"))


func speak(npc_id: String, key: String = "") -> Dictionary:
	var line: Dictionary
	if key == "":
		line = pick_line_for_flags(npc_id)
	else:
		line = get_line(npc_id, key)
	line_spoken.emit(npc_id, line)
	return line


func all_lines() -> Array:
	var out: Array = []
	var npcs: Dictionary = _data.get("npcs", {})
	for npc_id in npcs.keys():
		var lines: Dictionary = npcs[npc_id].get("lines", {})
		for key in lines.keys():
			var entry: Dictionary = lines[key].duplicate()
			entry["npc_id"] = npc_id
			entry["key"] = key
			out.append(entry)
	return out
