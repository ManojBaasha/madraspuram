extends SceneTree
## Iterates group pushable and fires receive_push; asserts reacted signal quickly.


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed: PackedScene = load("res://scenes/levels/george_street.tscn")
	var street: Node = packed.instantiate()
	root.add_child(street)
	await process_frame
	await process_frame
	await create_timer(0.3).timeout

	var nodes := street.get_tree().get_nodes_in_group("pushable")
	print("pushables found: ", nodes.size())
	if nodes.size() < 18:
		printerr("FAIL need >=18 pushables, got ", nodes.size())
		quit(1)
		return

	var failed := 0
	for n in nodes:
		var p: Pushable = n as Pushable
		if p == null:
			continue
		var flag := {"ok": false}
		var cb := func(_r: String) -> void:
			flag["ok"] = true
		p.reacted.connect(cb)
		var t0 := Time.get_ticks_msec()
		p.receive_push(Vector2.RIGHT)
		while not flag["ok"] and Time.get_ticks_msec() - t0 < 100:
			await process_frame
		if p.reacted.is_connected(cb):
			p.reacted.disconnect(cb)
		if not flag["ok"]:
			printerr("FAIL no reaction within 100ms: ", p.custom_id)
			failed += 1
		else:
			print("PASS reaction ", p.custom_id, " in ", Time.get_ticks_msec() - t0, "ms")

	print("--- reactions failed=", failed)
	quit(0 if failed == 0 else 1)
