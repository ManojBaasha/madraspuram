extends Node2D
## George Street — art pass + dense pushables + quest.

const STREET_W := 4800.0

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera2D
@onready var world: Node2D = $World
@onready var far_layer: Node2D = $Parallax/Far
@onready var mid_layer: Node2D = $Parallax/Mid
@onready var interactables: Node2D = $Interactables
@onready var subtitle: Label = $UI/Subtitle
@onready var bubble: Label = $UI/Bubble

var tea_bench: StaticBody2D
var auto_block: StaticBody2D
var milk_node: Area2D
var coconut: Node2D
var dog: Node2D
var _fare_hits: int = 0
var _tumbler_hits: int = 0


func _ready() -> void:
	GameState.reset()
	_build_world()
	Dialogue.line_spoken.connect(_on_line)
	GameState.flag_changed.connect(_on_flag)
	camera.bounds = Rect2(0, 0, STREET_W, 1080)
	_apply_fonts()
	await get_tree().create_timer(0.2).timeout
	Dialogue.speak("bus_conductor", "eject")
	GameState.add_alias("குட்டி")


func _process(_delta: float) -> void:
	# Cheap parallax follow
	if player:
		far_layer.position.x = -player.global_position.x * 0.15
		mid_layer.position.x = -player.global_position.x * 0.35
	if dog and GameState.get_flag("dog_following"):
		dog.global_position = dog.global_position.lerp(
			player.global_position + Vector2(-40, 10), 0.08
		)


func _apply_fonts() -> void:
	var tamil := load("res://fonts/NotoSansTamil-Regular.ttf")
	if tamil:
		bubble.add_theme_font_override("font", tamil)
	var hand := load("res://fonts/PatrickHand-Regular.ttf")
	if hand:
		subtitle.add_theme_font_override("font", hand)


func _build_world() -> void:
	_add_floor(0, STREET_W, 920)
	_sky_band()
	_sprite(far_layer, "res://art/svg/props/kolam.svg", Vector2(900, 860), 0.35)
	_sprite(mid_layer, "res://art/svg/bg/tea_kadai_slice.svg", Vector2(900, 480), 0.85)
	_sprite(world, "res://art/svg/props/signboard.svg", Vector2(1050, 520), 0.7)

	_label(80, 40, "1 BUS STOP")
	_label(1100, 40, "2 டீ கடை")
	_label(2600, 40, "3 ஆட்டோ")

	_sprite(world, "res://art/svg/props/auto.svg", Vector2(200, 720), 0.55)  # parked bus-side auto decor
	tea_bench = _static_blocker(1280, 880, 160, 40, Color(0.45, 0.3, 0.15), "TeaBench")
	auto_block = _static_blocker(2800, 820, 200, 90, Color(0.95, 0.76, 0.19), "AutoBlock")
	_sprite(auto_block, "res://art/svg/props/auto.svg", Vector2(0, -20), 0.7)
	coconut = _sprite(world, "res://art/svg/props/water_pot.svg", Vector2(3100, 780), 0.4)

	# Core quest pushables
	_make_pushable_sprite("TeaMaster", 1180, 820, "res://art/svg/chars/tea_master.svg", 0.45, "squash", _on_tea_pushed)
	_make_pushable_sprite("AutoDriver", 2860, 840, "res://art/svg/chars/tea_master.svg", 0.35, "wobble", _on_auto_pushed)
	milk_node = _make_pushable_sprite("Milk", 3300, 840, "res://art/svg/props/milk_packet.svg", 0.55, "launch", _on_milk_pushed)
	_make_pushable_sprite("DirectionsMan", 600, 840, "res://art/svg/chars/tea_master.svg", 0.35, "wobble", _on_directions)

	# Dense gag inventory (18+)
	_make_pushable_sprite("Bananas", 1500, 700, "res://art/svg/props/banana_bunch.svg", 0.5, "wobble", _on_bananas)
	_make_pushable_sprite("TeaGlasses", 1350, 780, "res://art/svg/props/tea_glasses.svg", 0.55, "squash", _on_glasses)
	_make_pushable_sprite("Radio", 1420, 760, "res://art/svg/props/water_pot.svg", 0.3, "spin", _on_radio)
	_make_pushable_sprite("Horn", 2750, 800, "res://art/svg/props/auto.svg", 0.25, "wobble", _on_horn)
	_make_pushable_sprite("Kolam", 880, 880, "res://art/svg/props/kolam.svg", 0.4, "squash", _on_kolam)
	_make_pushable_sprite("WireCrows", 400, 200, "res://art/svg/props/banana_bunch.svg", 0.2, "wobble", _on_crows)
	_make_pushable_sprite("WaterPot", 1600, 820, "res://art/svg/props/water_pot.svg", 0.5, "wobble", _on_pot)
	_make_pushable_sprite("Poster", 500, 700, "res://art/svg/props/cutout.svg", 0.25, "wobble", _on_poster)
	_make_pushable_sprite("Cutout", 3600, 700, "res://art/svg/props/cutout.svg", 0.55, "spin", _on_cutout)
	_make_pushable_sprite("Dog", 750, 860, "res://art/svg/props/water_pot.svg", 0.25, "squash", _on_dog)
	_make_pushable_sprite("Kids", 950, 850, "res://art/svg/chars/robot_full_confused.svg", 0.3, "launch", _on_kids)
	_make_pushable_sprite("BiscuitJar", 1250, 740, "res://art/svg/props/tea_glasses.svg", 0.35, "wobble")
	_make_pushable_sprite("Meter", 2920, 780, "res://art/svg/props/milk_packet.svg", 0.25, "fall", _on_meter)
	_make_pushable_sprite("SignSway", 1700, 600, "res://art/svg/props/signboard.svg", 0.4, "wobble")
	_make_pushable_sprite("CoconutStall", 3050, 840, "res://art/svg/props/water_pot.svg", 0.35, "fall", _on_coconut_stall)
	_make_pushable_sprite("BusLean", 180, 780, "res://art/svg/props/auto.svg", 0.4, "wobble", _on_bus)
	_make_pushable_sprite("SteamPot", 1100, 800, "res://art/svg/props/water_pot.svg", 0.35, "squash", _on_steam)
	_make_pushable_sprite("BenchRegular", 1550, 860, "res://art/svg/chars/tea_master.svg", 0.3, "wobble")

	dog = interactables.get_node_or_null("Dog")
	_update_blockers()
	_idle_all()


func _idle_all() -> void:
	for n in world.get_children():
		if n is Sprite2D or (n is Node2D and n.get_child_count() > 0 and n.get_child(0) is Sprite2D):
			if n.get_node_or_null("IdleLife") == null:
				var idle := IdleLife.new()
				idle.sway_deg = 1.2
				idle.speed = 0.8 + randf()
				n.add_child(idle)


func _sky_band() -> void:
	var sky := ColorRect.new()
	sky.size = Vector2(STREET_W, 1080)
	sky.color = Color(0.965, 0.906, 0.757)
	sky.z_index = -100
	far_layer.add_child(sky)
	# heat shimmer overlay
	var shim := ColorRect.new()
	shim.size = Vector2(STREET_W, 200)
	shim.position = Vector2(0, 700)
	shim.color = Color(1, 1, 1, 0.08)
	shim.z_index = 50
	world.add_child(shim)


func _sprite(parent: Node, path: String, pos: Vector2, scale_f: float) -> Node2D:
	var holder := Node2D.new()
	holder.position = pos
	var s := Sprite2D.new()
	if ResourceLoader.exists(path):
		s.texture = load(path)
	s.scale = Vector2(scale_f, scale_f)
	holder.add_child(s)
	parent.add_child(holder)
	return holder


func _on_directions(_d: Vector2, _c: int) -> void:
	Dialogue.speak("directions_man")


func _on_bananas(_d: Vector2, c: int) -> void:
	if c == 1:
		subtitle.text = "Banana: freefall. Crow: already budgeting."
		AudioBus.play_sfx("res://audio/sfx/crow.wav")


func _on_glasses(_d: Vector2, c: int) -> void:
	_tumbler_hits = c
	var path := "res://audio/sfx/clink.wav"
	if c % 3 == 2:
		path = "res://audio/sfx/clink2.wav"
	elif c % 3 == 0:
		path = "res://audio/sfx/clink3.wav"
	AudioBus.play_sfx(path)


func _on_radio(_d: Vector2, c: int) -> void:
	var j := "res://audio/sfx/jingle%d.wav" % (wrapi(c, 1, 4))
	AudioBus.play_sfx(j)


func _on_horn(_d: Vector2, _c: int) -> void:
	AudioBus.play_sfx("res://audio/sfx/horn.wav")
	await get_tree().create_timer(0.15).timeout
	AudioBus.play_sfx("res://audio/sfx/horn.wav", "SFX", 0.92)
	await get_tree().create_timer(0.12).timeout
	AudioBus.play_sfx("res://audio/sfx/horn.wav", "SFX", 1.08)


func _on_kolam(_d: Vector2, _c: int) -> void:
	Dialogue.speak("kolam_lady", "smudge")


func _on_crows(_d: Vector2, _c: int) -> void:
	AudioBus.play_sfx("res://audio/sfx/crow.wav")
	subtitle.text = "Crows: hop left. Union decision."


func _on_pot(_d: Vector2, c: int) -> void:
	if c >= 3:
		subtitle.text = "Pot: finally dramatic."


func _on_poster(_d: Vector2, c: int) -> void:
	subtitle.text = "Poster peel #%d — identical underneath." % c


func _on_cutout(_d: Vector2, _c: int) -> void:
	subtitle.text = "Cutout rotated 2°. Fans gasp (internally)."


func _on_dog(_d: Vector2, _c: int) -> void:
	GameState.set_flag("dog_following", true)
	subtitle.text = "Dog: employment acquired."


func _on_kids(_d: Vector2, _c: int) -> void:
	player.velocity.x = -player.facing * 320
	AudioBus.play_beep(1.4)
	subtitle.text = "Kids pushed back. Robot indignant."


func _on_meter(_d: Vector2, _c: int) -> void:
	subtitle.text = "Meter fell off. As designed."


func _on_coconut_stall(_d: Vector2, _c: int) -> void:
	if coconut:
		var tw := create_tween()
		tw.tween_property(coconut, "position:x", coconut.position.x + 800, 1.2)


func _on_bus(_d: Vector2, c: int) -> void:
	subtitle.text = "Bus lean angle: %d° of optimism." % (c * 3)


func _on_steam(_d: Vector2, _c: int) -> void:
	var heat := player.get_node_or_null("HeatBody")
	if heat:
		heat.set_in_sun(false)
		await get_tree().create_timer(2.0).timeout
		heat.set_in_sun(true)


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
	var tamil := load("res://fonts/NotoSansTamil-Regular.ttf")
	if tamil:
		l.add_theme_font_override("font", tamil)
	world.add_child(l)


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
	vis.modulate.a = 0.35
	body.add_child(vis)
	world.add_child(body)
	return body


func _make_pushable_sprite(
	named: String,
	x: float,
	y: float,
	tex_path: String,
	scale_f: float,
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
	rect.size = Vector2(64, 64)
	shape.shape = rect
	area.add_child(shape)
	var s := Sprite2D.new()
	if ResourceLoader.exists(tex_path):
		s.texture = load(tex_path)
	s.scale = Vector2(scale_f, scale_f)
	area.add_child(s)
	var p := Pushable.new()
	p.reaction = reaction
	p.custom_id = named
	p.sfx_path = "res://audio/sfx/push.wav"
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
	if tea_bench and GameState.get_flag("has_milk"):
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
