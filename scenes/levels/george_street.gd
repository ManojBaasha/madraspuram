extends Node2D
## George Street graybox — bus → tea → auto → milk → pour.

const STREET_W := 4800.0

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera2D
@onready var world: Node2D = $World
@onready var interactables: Node2D = $Interactables
@onready var subtitle: Label = $UI/Subtitle
@onready var bubble: Label = $UI/Bubble

var tea_bench: StaticBody2D
var auto_block: StaticBody2D
var milk_node: Area2D
var coconut: ColorRect
var _fare_hits: int = 0


func _ready() -> void:
	GameState.reset()
	_build_world()
	Dialogue.line_spoken.connect(_on_line)
	GameState.flag_changed.connect(_on_flag)
	camera.bounds = Rect2(0, 0, STREET_W, 1080)
	await get_tree().create_timer(0.2).timeout
	Dialogue.speak("bus_conductor", "eject")
	GameState.add_alias("குட்டி")


func _build_world() -> void:
	# Floor
	_add_floor(0, STREET_W, 920)
	# Zone labels
	_label(80, 40, "1 BUS STOP")
	_label(1100, 40, "2 TEA KADAI")
	_label(2600, 40, "3 AUTO + MILK")

	# Bus (decor)
	_rect_decor(120, 700, 220, 200, Color(0.45, 0.55, 0.35), "Bus")

	# Tea kadai block
	_rect_decor(1000, 620, 360, 280, Color(0.91, 0.79, 0.55), "Kadai")
	tea_bench = _static_blocker(1280, 860, 160, 40, Color(0.45, 0.3, 0.15), "TeaBench")

	# Auto blocker
	auto_block = _static_blocker(2800, 820, 200, 80, Color(0.95, 0.76, 0.19), "AutoBlock")
	coconut = _rect_decor(3100, 780, 60, 60, Color(0.45, 0.55, 0.25), "Coconut")

	# Pushable NPCs / props
	_make_pushable("TeaMaster", 1180, 850, Color(0.24, 0.44, 0.69), "squash", _on_tea_pushed)
	_make_pushable("AutoDriver", 2850, 850, Color(0.7, 0.4, 0.2), "wobble", _on_auto_pushed)
	milk_node = _make_pushable("Milk", 3300, 850, Color(0.95, 0.95, 0.9), "launch", _on_milk_pushed)
	_make_pushable("DirectionsMan", 600, 850, Color(0.6, 0.5, 0.4), "wobble", _on_directions)
	_make_pushable("Radio", 1400, 780, Color(0.7, 0.23, 0.18), "spin")
	_make_pushable("Bananas", 1500, 760, Color(0.91, 0.78, 0.29), "wobble")

	_update_blockers()


func _on_directions(_d: Vector2, _c: int) -> void:
	Dialogue.speak("directions_man")


func _add_floor(x0: float, x1: float, y: float) -> void:
	var body := StaticBody2D.new()
	body.position = Vector2((x0 + x1) * 0.5, y)
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(x1 - x0, 40)
	shape.shape = rect
	body.add_child(shape)
	var vis := ColorRect.new()
	vis.size = Vector2(x1 - x0, 40)
	vis.position = Vector2(-(x1 - x0) * 0.5, -20)
	vis.color = Color(0.76, 0.65, 0.45)
	body.add_child(vis)
	world.add_child(body)


func _label(x: float, y: float, text: String) -> void:
	var l := Label.new()
	l.text = text
	l.position = Vector2(x, y)
	l.add_theme_font_size_override("font_size", 28)
	world.add_child(l)


func _rect_decor(x: float, y: float, w: float, h: float, color: Color, named: String) -> ColorRect:
	var r := ColorRect.new()
	r.name = named
	r.size = Vector2(w, h)
	r.position = Vector2(x, y)
	r.color = color
	world.add_child(r)
	return r


func _static_blocker(x: float, y: float, w: float, h: float, color: Color, named: String) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.name = named
	body.position = Vector2(x, y)
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(w, h)
	shape.shape = rect
	body.add_child(shape)
	var vis := ColorRect.new()
	vis.size = Vector2(w, h)
	vis.position = Vector2(-w * 0.5, -h * 0.5)
	vis.color = color
	body.add_child(vis)
	# shift shape to center
	shape.position = Vector2.ZERO
	world.add_child(body)
	return body


func _make_pushable(
	named: String,
	x: float,
	y: float,
	color: Color,
	reaction: String,
	cb: Callable = Callable(),
) -> Area2D:
	var area := Area2D.new()
	area.name = named
	area.position = Vector2(x, y)
	area.collision_layer = 8
	area.collision_mask = 0
	area.monitoring = false
	area.monitorable = true
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(56, 56)
	shape.shape = rect
	area.add_child(shape)
	var vis := ColorRect.new()
	vis.size = Vector2(56, 56)
	vis.position = Vector2(-28, -28)
	vis.color = color
	area.add_child(vis)
	var tag := Label.new()
	tag.text = named
	tag.position = Vector2(-30, -48)
	tag.add_theme_font_size_override("font_size", 12)
	area.add_child(tag)
	var p := Pushable.new()
	p.reaction = reaction
	p.custom_id = named
	area.add_child(p)
	if cb.is_valid():
		p.pushed.connect(cb)
	interactables.add_child(area)
	return area


func _on_line(_npc: String, line: Dictionary) -> void:
	bubble.text = str(line.get("ta", ""))
	subtitle.text = str(line.get("en_subtitle", ""))
	bubble.visible = true
	subtitle.visible = true


func _on_flag(flag_name: String, value: Variant) -> void:
	if value:
		_update_blockers()
	if flag_name == "tea_done" and value:
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://scenes/ui/end_card.tscn")


func _update_blockers() -> void:
	# Tea bench is scenic after milk; only auto hard-blocks the milk lane.
	if tea_bench:
		if GameState.get_flag("has_milk"):
			tea_bench.visible = false
			tea_bench.set_collision_layer_value(1, false)
	if auto_block:
		var block_auto: bool = not GameState.get_flag("auto_moved")
		auto_block.visible = block_auto
		auto_block.set_collision_layer_value(1, block_auto)


func _on_tea_pushed(_dir: Vector2, _count: int) -> void:
	if GameState.get_flag("has_milk") and not GameState.get_flag("tea_done"):
		Dialogue.speak("tea_master", "got_milk")
		await get_tree().create_timer(0.5).timeout
		GameState.set_flag("tea_done", true)
		GameState.add_alias("ரோபோ தம்பி")
		var heat := player.get_node_or_null("HeatBody")
		if heat:
			heat.splash_cool(0.8)
		Dialogue.speak("tea_master", "after_tea")
	else:
		Dialogue.speak("tea_master")


func _on_auto_pushed(_dir: Vector2, count: int) -> void:
	if GameState.get_flag("auto_moved"):
		Dialogue.speak("auto_driver", "moved")
		return
	_fare_hits = count
	if count == 1:
		Dialogue.speak("auto_driver", "sleeping")
	elif count < 5:
		Dialogue.speak("auto_driver", "fare")
	else:
		GameState.set_flag("auto_moved", true)
		Dialogue.speak("auto_driver", "moved")
		var tw := create_tween()
		tw.tween_property(auto_block, "position:x", auto_block.position.x + 420, 0.55)
		if coconut:
			tw.parallel().tween_property(coconut, "position:y", coconut.position.y + 220, 0.7)


func _on_milk_pushed(_dir: Vector2, _count: int) -> void:
	if GameState.get_flag("auto_moved") and not GameState.get_flag("has_milk"):
		GameState.set_flag("has_milk", true)
		milk_node.visible = false
		for c in milk_node.get_children():
			if c is CollisionShape2D:
				c.set_deferred("disabled", true)
		subtitle.text = "Acquired: white packet (milk, allegedly)"
		_update_blockers()
