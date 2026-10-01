extends SceneTree

## Tiny custom test runner. Loads tests/test_*.gd and runs test_* methods.


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var dir := DirAccess.open("res://tests")
	if dir == null:
		printerr("FAIL: cannot open res://tests")
		quit(1)
		return

	var files: Array[String] = []
	dir.list_dir_begin()
	var fname := dir.get_next()
	while fname != "":
		if not dir.current_is_dir() and fname.begins_with("test_") and fname.ends_with(".gd"):
			files.append(fname)
		fname = dir.get_next()
	dir.list_dir_end()
	files.sort()

	var passed := 0
	var failed := 0
	var total := 0

	if files.is_empty():
		print("0 tests — PASS (clean)")
		quit(0)
		return

	for file_name in files:
		var script: GDScript = load("res://tests/%s" % file_name)
		if script == null:
			printerr("FAIL: could not load %s" % file_name)
			failed += 1
			continue
		var inst = script.new()
		for method in inst.get_method_list():
			var mname: String = method.name
			if not mname.begins_with("test_"):
				continue
			total += 1
			var err: Variant = inst.call(mname)
			if err == null or err == true or err == OK:
				print("PASS %s.%s" % [file_name, mname])
				passed += 1
			else:
				printerr("FAIL %s.%s — %s" % [file_name, mname, str(err)])
				failed += 1
		if inst is Node:
			inst.free()

	print("---")
	print("%d passed, %d failed, %d total" % [passed, failed, total])
	quit(0 if failed == 0 else 1)
