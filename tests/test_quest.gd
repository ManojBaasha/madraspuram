extends RefCounted


func test_quest_flag_order() -> Variant:
	GameState.reset()
	var order := ["auto_moved", "has_milk", "tea_done"]
	var seen: Array[String] = []
	GameState.flag_changed.connect(func(n: String, v: Variant) -> void:
		if v:
			seen.append(n)
	)
	for f in order:
		GameState.set_flag(f, true)
	if seen != order:
		return "expected %s got %s" % [str(order), str(seen)]
	return true


func test_dialogue_keys_exist() -> Variant:
	Dialogue.reload()
	var lines: Array = Dialogue.all_lines()
	if lines.is_empty():
		return "no dialogue lines"
	for line in lines:
		if str(line.get("ta", "")).is_empty():
			return "empty ta in %s" % line.get("key")
		if str(line.get("en_subtitle", "")).is_empty():
			return "empty subtitle in %s" % line.get("key")
		if str(line.get("ta", "")).length() > 80:
			return "ta too long: %s" % line.get("key")
	return true
