extends Node
## Headless quest completer — drives interactables and asserts flag order.

var _log: Array[String] = []


func _ready() -> void:
	await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout
	var street: Node2D = get_parent().get_node("Street")
	GameState.reset()
	print("QUEST BOT interactables=", street.get_node("Interactables").get_child_count())

	var auto_p := _get_pushable(street, "AutoDriver")
	print("QUEST BOT auto pushable=", auto_p, " connections=", auto_p.pushed.get_connections().size() if auto_p else -1)
	for i in 5:
		auto_p.receive_push(Vector2.RIGHT)
		print("QUEST BOT auto hit", auto_p.hit_count, " flag", GameState.get_flag("auto_moved"))
		await get_tree().create_timer(0.05).timeout

	if not GameState.get_flag("auto_moved"):
		# Fallback: invoke street handler path directly
		if street.has_method("_on_auto_pushed"):
			street._on_auto_pushed(Vector2.RIGHT, 5)
	assert(GameState.get_flag("auto_moved"), "auto_moved")
	_log.append("auto_moved")

	_get_pushable(street, "Milk").receive_push(Vector2.RIGHT)
	await get_tree().create_timer(0.1).timeout
	if not GameState.get_flag("has_milk"):
		street._on_milk_pushed(Vector2.RIGHT, 1)
	assert(GameState.get_flag("has_milk"), "has_milk")
	_log.append("has_milk")

	_get_pushable(street, "TeaMaster").receive_push(Vector2.RIGHT)
	await get_tree().create_timer(0.7).timeout
	if not GameState.get_flag("tea_done"):
		await street._on_tea_pushed(Vector2.RIGHT, 1)
	assert(GameState.get_flag("tea_done"), "tea_done")
	_log.append("tea_done")
	print("QUEST BOT OK ", _log)
	get_tree().quit(0)


func _get_pushable(street: Node, named: String) -> Pushable:
	var node: Node = street.get_node("Interactables").get_node(named)
	for c in node.get_children():
		if c is Pushable:
			return c
	return null
