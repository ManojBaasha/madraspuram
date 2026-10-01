extends RefCounted


func test_pushables_have_sfx_path() -> Variant:
	# Structural: Pushable default sfx exists
	if not ResourceLoader.exists("res://audio/sfx/push.wav"):
		return "missing push.wav"
	return true


func test_all_dialogue_confidence() -> Variant:
	Dialogue.reload()
	for line in Dialogue.all_lines():
		var c: String = str(line.get("confidence", ""))
		if c not in ["high", "medium", "low"]:
			return "bad confidence on %s" % line.get("key")
	return true


func test_strings_exist() -> Variant:
	if not FileAccess.file_exists("res://data/strings.json"):
		return "missing strings.json"
	return true
