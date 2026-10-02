extends Node2D
## George Street — visual pass focused on readable 2.5D depth (TGYH-like plaza).

const STREET_W := 4800.0
const WALK_MIN_Y := 680.0
const WALK_MAX_Y := 1000.0
const SIDEWALK_Y := 700.0  # shop faces sit here
const ROAD_Y := 860.0

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera2D
@onready var world: Node2D = $World
@onready var far_layer: Node2D = $Parallax/Far
@onready var mid_layer: Node2D = $Parallax/Mid
@onready var interactables: Node2D = $Interactables
@onready var subtitle: Label = $UI/Subtitle
@onready var bubble: Label = $UI/Bubble

var auto_block: StaticBody2D
var milk_node: Area2D
var coconut: Node2D
var dog: Node2D
var _line_tween: Tween
var _fare_hits: int = 0
var _sway_nodes: Array = []
var _crow_nodes: Array = []
var _idle_actors: Array = []  # {node, base_y, kind, phase}
var _idle_t: float = 0.0


func _ready() -> void:
	GameState.reset()
	world.y_sort_enabled = true
	interactables.y_sort_enabled = true
	_style_ui()
	_build_sky_and_depth()
	_build_plaza()
	_build_shops()
	_build_quest_actors()
	_build_gags()
	Dialogue.line_spoken.connect(_on_line)
	GameState.flag_changed.connect(_on_flag)
	camera.bounds = Rect2(0, 0, STREET_W, 1080)
	camera.look_ahead = 90.0
	camera.zoom = Vector2(0.82, 0.82)  # pull back — TGYH shows more ground around the little guy
	player.position = Vector2(320, 900)
	player.set_walk_bounds(Rect2(80, WALK_MIN_Y, STREET_W - 160, WALK_MAX_Y - WALK_MIN_Y))
	_add_player_shadow()
	_update_blockers()
	GameState.add_alias("குட்டி")
	_build_ground_life()  # micro-detail fills space without crowding interactables
	if ResourceLoader.exists("res://audio/sfx/ambient_street.wav"):
		AudioBus.play_sfx("res://audio/sfx/ambient_street.wav", "SFX", 1.0, -12.0)
	# Fade control hint so it doesn't sit forever
	var hint := $UI.get_node_or_null("Hint")
	if hint:
		await get_tree().create_timer(2.5).timeout
		var tw := create_tween()
		tw.tween_property(hint, "modulate:a", 0.0, 0.6)


func _process(delta: float) -> void:
	_idle_t += delta
	if player:
		far_layer.position.x = -player.global_position.x * 0.1
		mid_layer.position.x = -player.global_position.x * 0.25
	if dog and GameState.get_flag("dog_following") and is_instance_valid(dog):
		dog.global_position = dog.global_position.lerp(
			player.global_position + Vector2(-50 * player.facing, 12), 0.12
		)
		dog.z_index = int(dog.global_position.y)
	for i in _sway_nodes.size():
		var n: Node2D = _sway_nodes[i]
		if is_instance_valid(n):
			n.rotation_degrees = sin(_idle_t * 1.4 + i * 0.7) * 1.8
			if n.has_meta("blink") and n.has_meta("glow"):
				var g: ColorRect = n.get_meta("glow")
				if is_instance_valid(g):
					var pulse := 0.55 + 0.45 * (0.5 + 0.5 * sin(_idle_t * 3.2 + i * 1.1))
					g.modulate = Color(1, 1, 1, pulse)
	for i in _crow_nodes.size():
		var c: Node2D = _crow_nodes[i]
		if is_instance_valid(c):
			c.position.y = float(c.get_meta("base_y")) + sin(_idle_t * 3.0 + i) * 2.0
	for i in _idle_actors.size():
		var d: Dictionary = _idle_actors[i]
		var n: Node2D = d["node"]
		if not is_instance_valid(n):
			continue
		# don't fight dog follow lerp for Y when following
		if n == dog and GameState.get_flag("dog_following"):
			n.rotation_degrees = sin(_idle_t * 4.0 + d["phase"]) * 3.0
			continue
		var kind: String = d["kind"]
		var ph: float = d["phase"]
		var base_y: float = d["base_y"]
		match kind:
			"breathe":
				n.position.y = base_y + sin(_idle_t * 1.6 + ph) * 2.5
				n.rotation_degrees = sin(_idle_t * 1.1 + ph) * 1.2
			"pour":
				n.position.y = base_y + sin(_idle_t * 2.2 + ph) * 3.5
				n.rotation_degrees = sin(_idle_t * 2.0 + ph) * 2.5
			"point":
				n.rotation_degrees = sin(_idle_t * 1.3 + ph) * 3.5
				n.position.y = base_y + sin(_idle_t * 1.0 + ph) * 1.5
			"hop":
				n.position.y = base_y + abs(sin(_idle_t * 3.5 + ph)) * -6.0
			"pant":
				n.position.y = base_y + sin(_idle_t * 5.0 + ph) * 2.0
				n.rotation_degrees = sin(_idle_t * 4.5 + ph) * 4.0
			"wobble":
				n.rotation_degrees = sin(_idle_t * 2.0 + ph) * 4.0
				n.position.y = base_y + sin(_idle_t * 1.5 + ph) * 2.0
			_:
				n.position.y = base_y + sin(_idle_t * 1.4 + ph) * 2.0
		n.z_index = int(n.position.y)


func _style_ui() -> void:
	var tamil = load("res://fonts/NotoSansTamil-Regular.ttf")
	var hand = load("res://fonts/PatrickHand-Regular.ttf")
	if tamil:
		bubble.add_theme_font_override("font", tamil)
		bubble.add_theme_font_size_override("font_size", 24)
	if hand:
		subtitle.add_theme_font_override("font", hand)
		subtitle.add_theme_font_size_override("font_size", 20)
	bubble.add_theme_color_override("font_color", Color(0.12, 0.08, 0.05))
	subtitle.add_theme_color_override("font_color", Color(0.12, 0.08, 0.05))
	# pivot for pop-in scale
	await get_tree().process_frame
	if bubble.size.x > 0:
		bubble.pivot_offset = bubble.size * 0.5


func _add_player_shadow() -> void:
	var sh := Polygon2D.new()
	sh.name = "Shadow"
	sh.color = Color(0, 0, 0, 0.22)
	sh.polygon = PackedVector2Array([
		Vector2(-28, 4), Vector2(28, 4), Vector2(22, 14), Vector2(-22, 14)
	])
	sh.z_index = -1
	player.add_child(sh)


func _build_sky_and_depth() -> void:
	# Soft heat-sky bands (not one flat void)
	var bands := [
		[Color("F8EDD0"), 0.0, 220.0],
		[Color("F6E7C1"), 220.0, 260.0],
		[Color("EFD9A8"), 480.0, 280.0],
	]
	for band in bands:
		var sky := ColorRect.new()
		sky.size = Vector2(STREET_W + 600, band[2])
		sky.position = Vector2(-300, band[1])
		sky.color = band[0]
		sky.z_index = -100
		far_layer.add_child(sky)
	# Continuous skyline strip sitting on the sidewalk horizon (no floating boxes)
	var skyline_base := SIDEWALK_Y - 8.0
	var x := -120.0
	var i := 0
	while x < STREET_W + 200:
		var w := 90.0 + float((i * 37) % 110)
		var h := 70.0 + float((i * 53) % 120)
		var plaster := Color(0.72, 0.55, 0.36).darkened(0.08 + (i % 4) * 0.04)
		var b := ColorRect.new()
		b.size = Vector2(w, h)
		b.position = Vector2(x, skyline_base - h)
		b.color = plaster
		b.z_index = -90
		far_layer.add_child(b)
		# tiny distant windows
		var cols := clampi(int(w / 28.0), 1, 4)
		var rows := clampi(int(h / 36.0), 1, 3)
		for row in rows:
			for col in cols:
				if (i + row + col) % 5 == 0:
					continue
				var win := ColorRect.new()
				win.size = Vector2(8, 10)
				win.position = Vector2(
					x + 10 + col * (w - 20) / maxf(cols, 1),
					skyline_base - h + 14 + row * 22
				)
				win.color = Color(0.35, 0.42, 0.5, 0.55) if (i + col) % 3 != 0 else Color(0.9, 0.75, 0.4, 0.45)
				win.z_index = -89
				far_layer.add_child(win)
		# roof edge coping
		var cope := ColorRect.new()
		cope.size = Vector2(w + 4, 5)
		cope.position = Vector2(x - 2, skyline_base - h - 3)
		cope.color = plaster.darkened(0.15)
		cope.z_index = -89
		far_layer.add_child(cope)
		# water tank / dish on some roofs
		if i % 3 == 0:
			var tank := ColorRect.new()
			tank.size = Vector2(18, 22)
			tank.position = Vector2(x + w * 0.45, skyline_base - h - 22)
			tank.color = Color(0.55, 0.42, 0.3)
			tank.z_index = -88
			far_layer.add_child(tank)
		if i % 4 == 1:
			var dish := ColorRect.new()
			dish.size = Vector2(14, 3)
			dish.position = Vector2(x + w * 0.2, skyline_base - h - 10)
			dish.color = Color(0.75, 0.75, 0.78)
			dish.z_index = -88
			far_layer.add_child(dish)
			var pole := ColorRect.new()
			pole.size = Vector2(2, 12)
			pole.position = Vector2(x + w * 0.2 + 6, skyline_base - h - 10)
			pole.color = Color(0.3, 0.25, 0.2)
			pole.z_index = -88
			far_layer.add_child(pole)
		x += w - 8.0
		i += 1
	# Cables
	for yoff in [70.0, 95.0]:
		var cable := Line2D.new()
		cable.width = 2.0
		cable.default_color = Color(0.17, 0.11, 0.08, 0.7)
		cable.z_index = -80
		for cx in range(0, int(STREET_W), 70):
			cable.add_point(Vector2(cx, yoff + sin(cx * 0.012) * 8))
		far_layer.add_child(cable)
	# Crows on the lower cable
	for ci in 8:
		var crow := Polygon2D.new()
		crow.color = Color("2B1D14")
		crow.polygon = PackedVector2Array([
			Vector2(-5, 0), Vector2(0, -4), Vector2(5, 0), Vector2(0, 3)
		])
		var cx := 180.0 + ci * 520.0
		var cy := 95.0 + sin(ci) * 6.0
		crow.position = Vector2(cx, cy)
		crow.set_meta("base_y", cy)
		crow.z_index = -79
		far_layer.add_child(crow)
		_crow_nodes.append(crow)


func _build_plaza() -> void:
	var road_back := ColorRect.new()
	road_back.position = Vector2(-200, SIDEWALK_Y)
	road_back.size = Vector2(STREET_W + 400, WALK_MAX_Y - SIDEWALK_Y + 100)
	road_back.color = Color("B8956A")
	road_back.z_index = -50
	world.add_child(road_back)

	var sidewalk := ColorRect.new()
	sidewalk.position = Vector2(-200, SIDEWALK_Y)
	sidewalk.size = Vector2(STREET_W + 400, 70)
	sidewalk.color = Color("D2B48C")
	sidewalk.z_index = -49
	world.add_child(sidewalk)

	for i in range(0, int(STREET_W), 90):
		var slab := ColorRect.new()
		slab.position = Vector2(i, SIDEWALK_Y + 8)
		slab.size = Vector2(78, 48)
		slab.color = Color("CDB892").darkened((i % 3) * 0.03)
		slab.z_index = -48
		world.add_child(slab)

	var road_mid := ColorRect.new()
	road_mid.position = Vector2(-200, ROAD_Y - 50)
	road_mid.size = Vector2(STREET_W + 400, 120)
	road_mid.color = Color("C4A574")
	road_mid.z_index = -47
	world.add_child(road_mid)

	for i in range(40, int(STREET_W), 120):
		var dash := ColorRect.new()
		dash.position = Vector2(i, ROAD_Y + 10)
		dash.size = Vector2(48, 5)
		dash.color = Color(0.92, 0.85, 0.65, 0.35)
		dash.z_index = -46
		world.add_child(dash)

	var road_front := ColorRect.new()
	road_front.position = Vector2(-200, 930)
	road_front.size = Vector2(STREET_W + 400, 150)
	road_front.color = Color("A8845A")
	road_front.z_index = -45
	world.add_child(road_front)

	var curb := ColorRect.new()
	curb.position = Vector2(-200, SIDEWALK_Y + 66)
	curb.size = Vector2(STREET_W + 400, 8)
	curb.color = Color("2B1D14")
	curb.z_index = -44
	world.add_child(curb)

	_wall(STREET_W * 0.5, WALK_MIN_Y - 25, STREET_W + 400, 40)
	_wall(STREET_W * 0.5, WALK_MAX_Y + 35, STREET_W + 400, 40)
	_wall(-50, 840, 50, 500)
	_wall(STREET_W + 50, 840, 50, 500)


func _wall(x: float, y: float, w: float, h: float) -> void:
	var body := StaticBody2D.new()
	body.position = Vector2(x, y)
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(w, h)
	shape.shape = rect
	body.add_child(shape)
	world.add_child(body)


func _build_shops() -> void:
	# Mid facades — each variant reads differently (shutter vs door, awning colors)
	_mid_facade(520, 260, Color("E2C48A"), Color("3E6FB0"), 0)
	_mid_facade(920, 240, Color("DCC08A"), Color("B23A2E"), 1)
	_mid_facade(1880, 280, Color("E6C99A"), Color("1F3B2C"), 2)
	_mid_facade(2280, 250, Color("E0C090"), Color("3E6FB0"), 3)
	_mid_facade(3400, 270, Color("D8BA88"), Color("B23A2E"), 4)
	# Extra filler façades so the street isn't empty between hubs
	_mid_facade(1600, 220, Color("E8CFA0"), Color("C8763A"), 5)
	_mid_facade(2680, 230, Color("D4B888"), Color("3F6B3A"), 6)

	# Zone 1 — bus
	_shop_block(80, SIDEWALK_Y - 210, 240, 210, Color("3E6FB0"), Color("2B1D14"),
		"பஸ் நிறுத்தம்", "BUS STOP")
	_prop_sprite("res://art/svg/props/auto.svg", Vector2(200, 820), 0.9)

	# Zone 2 — tea hub
	var kadai := _prop_sprite("res://art/svg/bg/tea_kadai_slice.svg", Vector2(1350, SIDEWALK_Y + 10), 0.82)
	kadai.z_index = int(SIDEWALK_Y) - 5

	# Zone 3 — auto stand
	_shop_block(2900, SIDEWALK_Y - 200, 400, 200, Color("E6B422"), Color("1F3B2C"),
		"ஆட்டோ நிலையம்", "AUTO STAND · NO METER")
	# Zone 4 — poster wall
	_shop_block(3800, SIDEWALK_Y - 230, 360, 230, Color("B23A2E").lightened(0.12), Color("2B1D14"),
		"மாஸ் ஹீரோ சுந்தர்", "NEW MASS HIT")

	_build_street_signs()


func _build_street_signs() -> void:
	## Real Chennai walls: Tamil big, English small / mixed, phones, imperfect paint.
	_board(40, SIDEWALK_Y - 250, 200, 56, Color("FBF7EE"), Color("2B1D14"),
		"ஜார்ஜ் தெரு", "GEORGE STREET", -1.5)
	_board(1180, SIDEWALK_Y - 195, 340, 88, Color("3E6FB0"), Color("FBF7EE"),
		"முருகன் டீ கடை", "MURUGAN TEA SHOP\nSince 1987 · 98400 11223", 1.2)
	_board(1580, SIDEWALK_Y - 150, 150, 92, Color("1A1A1A"), Color("FBF7EE"),
		"டீ  ₹12\nகாபி ₹15", "TIFFIN READY", -2.0)
	_board(720, SIDEWALK_Y - 175, 120, 64, Color("B23A2E"), Color("FBF7EE"),
		"எஸ்.டி.டி", "STD ISD PCO", 0.8)
	_board(430, SIDEWALK_Y - 155, 100, 60, Color("FBF7EE"), Color("B23A2E"),
		"பார்க்கிங்\nகூடாது", "NO PARKING", -1.0)
	_board(2520, SIDEWALK_Y - 150, 150, 72, Color("FBF7EE"), Color("3E6FB0"),
		"பாவின் பால்", "PAAVIN MILK\nAgent", 1.5)
	_board(3220, SIDEWALK_Y - 175, 170, 80, Color("1F3B2C"), Color("F2C230"),
		"குறைந்த கட்டணம்", "MIN ₹50 · NO METER", -0.5)
	_board(2050, SIDEWALK_Y - 185, 210, 78, Color("C8763A"), Color("FBF7EE"),
		"ஹோட்டல் அண்ணா", "MEALS READY\nVEG · NON-VEG", 2.0)
	_board(2380, SIDEWALK_Y - 140, 130, 56, Color("F2C230"), Color("2B1D14"),
		"கரண்ட் போச்சு", "POWER CUT", -2.5)
	_board(860, SIDEWALK_Y - 130, 110, 50, Color("3F6B3A"), Color("FFFDF4"),
		"மல்லிகை", "JASMINE ₹20", 1.0)
	_board(3980, SIDEWALK_Y - 260, 180, 66, Color("2B1D14"), Color("F2C230"),
		"இன்று முதல்", "FROM TODAY", 0.0)
	_board(1780, SIDEWALK_Y - 115, 130, 58, Color("E9C98B"), Color("2B1D14"),
		"டீ · பஃப்", "TEA · PUFF", -1.8)


func _board(
	x: float,
	y: float,
	w: float,
	h: float,
	bg: Color,
	fg: Color,
	ta: String,
	en: String,
	rot_deg: float = 0.0,
) -> void:
	var root := Node2D.new()
	root.position = Vector2(x + w * 0.5, y + h * 0.5)
	root.rotation_degrees = rot_deg
	root.z_index = int(SIDEWALK_Y) - 8
	var border := ColorRect.new()
	border.size = Vector2(w + 6, h + 6)
	border.position = Vector2(-w * 0.5 - 3, -h * 0.5 - 3)
	border.color = Color("2B1D14")
	root.add_child(border)
	var plate := ColorRect.new()
	plate.size = Vector2(w, h)
	plate.position = Vector2(-w * 0.5, -h * 0.5)
	plate.color = bg
	root.add_child(plate)

	var tamil_f = load("res://fonts/NotoSansTamil-Regular.ttf")
	var bold_f = load("res://fonts/NotoSansTamil-Bold.ttf")
	var hand_f = load("res://fonts/PatrickHand-Regular.ttf")

	var ta_l := Label.new()
	ta_l.text = ta
	ta_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ta_l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	ta_l.size = Vector2(w - 10, h * 0.58)
	ta_l.position = Vector2(-w * 0.5 + 5, -h * 0.5 + 4)
	ta_l.add_theme_color_override("font_color", fg)
	ta_l.add_theme_font_size_override("font_size", clampi(int(h * 0.28), 14, 26))
	if bold_f:
		ta_l.add_theme_font_override("font", bold_f)
	elif tamil_f:
		ta_l.add_theme_font_override("font", tamil_f)
	ta_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(ta_l)

	if en != "":
		var en_l := Label.new()
		en_l.text = en
		en_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		en_l.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		en_l.size = Vector2(w - 10, h * 0.4)
		en_l.position = Vector2(-w * 0.5 + 5, h * 0.08)
		var en_col := fg.darkened(0.08) if fg.get_luminance() > 0.5 else fg.lightened(0.12)
		en_l.add_theme_color_override("font_color", en_col)
		en_l.add_theme_font_size_override("font_size", clampi(int(h * 0.16), 10, 16))
		if hand_f:
			en_l.add_theme_font_override("font", hand_f)
		en_l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		root.add_child(en_l)

	world.add_child(root)
	_sway_nodes.append(root)


func _build_ground_life() -> void:
	## TGYH trick: ground feels dense via cracks/weeds/litter while big props stay spaced.
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	for _i in 48:
		var px := rng.randf_range(100.0, STREET_W - 100.0)
		var py := rng.randf_range(WALK_MIN_Y + 20.0, WALK_MAX_Y - 10.0)
		var stain := Polygon2D.new()
		stain.color = Color(0.35, 0.22, 0.12, 0.18)
		var len := rng.randf_range(18.0, 55.0)
		stain.polygon = PackedVector2Array([
			Vector2(0, 0), Vector2(len, rng.randf_range(-4, 4)),
			Vector2(len * 0.9, 3), Vector2(0, 2)
		])
		stain.position = Vector2(px, py)
		stain.z_index = int(py) - 40
		world.add_child(stain)
	for _j in 36:
		var weed := Line2D.new()
		weed.width = 2.0
		weed.default_color = Color(0.28, 0.42, 0.18, 0.75)
		var wx := rng.randf_range(80.0, STREET_W - 80.0)
		var wy := rng.randf_range(WALK_MIN_Y + 10.0, WALK_MAX_Y)
		weed.add_point(Vector2(wx, wy))
		weed.add_point(Vector2(wx + rng.randf_range(-4, 4), wy - rng.randf_range(6, 14)))
		weed.z_index = int(wy) - 30
		world.add_child(weed)
	for _k in 28:
		var bit := ColorRect.new()
		bit.size = Vector2(rng.randf_range(3, 7), rng.randf_range(2, 5))
		bit.position = Vector2(rng.randf_range(60.0, STREET_W - 60.0), rng.randf_range(WALK_MIN_Y, WALK_MAX_Y))
		bit.color = Color(0.55, 0.35, 0.2).lightened(rng.randf_range(-0.1, 0.2))
		bit.z_index = int(bit.position.y) - 35
		world.add_child(bit)
	for fi in 12:
		var flower := Polygon2D.new()
		flower.color = Color("FFFDF4")
		var fx := 180.0 + fi * 380.0 + rng.randf_range(-40, 40)
		var fy := SIDEWALK_Y + 58.0 + rng.randf_range(0, 20)
		flower.polygon = PackedVector2Array([
			Vector2(-4, 0), Vector2(0, -6), Vector2(4, 0), Vector2(0, 3)
		])
		flower.position = Vector2(fx, fy)
		flower.z_index = int(fy) - 20
		world.add_child(flower)


func _mid_facade(x: float, w: float, wall: Color, trim: Color, variant: int = 0) -> void:
	## Mid-street plaster face — windows, shutters, awning, pipe, stains (not a blank ColorRect).
	var h := 200.0 + float(variant % 3) * 18.0
	var y := SIDEWALK_Y - h
	var z0 := -70

	var wall_r := ColorRect.new()
	wall_r.position = Vector2(x, y)
	wall_r.size = Vector2(w, h)
	wall_r.color = wall
	wall_r.z_index = z0
	mid_layer.add_child(wall_r)

	# plaster stains / peeling patches
	for si in 3:
		var stain := ColorRect.new()
		stain.size = Vector2(18 + (si * 11) % 28, 30 + (si * 17) % 40)
		stain.position = Vector2(x + 16 + si * (w * 0.28), y + 40 + (si * 23) % 60)
		stain.color = wall.darkened(0.08 + si * 0.03)
		stain.modulate.a = 0.55
		stain.z_index = z0 + 1
		mid_layer.add_child(stain)

	# vertical drain pipe
	var pipe_x := x + w - 14.0 if variant % 2 == 0 else x + 10.0
	var pipe := ColorRect.new()
	pipe.position = Vector2(pipe_x, y + 18)
	pipe.size = Vector2(6, h - 22)
	pipe.color = Color(0.45, 0.4, 0.35)
	pipe.z_index = z0 + 2
	mid_layer.add_child(pipe)
	var elbow := ColorRect.new()
	elbow.position = Vector2(pipe_x - 4, y + h - 18)
	elbow.size = Vector2(14, 6)
	elbow.color = Color(0.4, 0.35, 0.3)
	elbow.z_index = z0 + 2
	mid_layer.add_child(elbow)

	# roof coping + fascia band
	var cope := ColorRect.new()
	cope.position = Vector2(x - 4, y - 6)
	cope.size = Vector2(w + 8, 8)
	cope.color = wall.darkened(0.18)
	cope.z_index = z0 + 3
	mid_layer.add_child(cope)
	var fascia := ColorRect.new()
	fascia.position = Vector2(x, y)
	fascia.size = Vector2(w, 26)
	fascia.color = trim
	fascia.z_index = z0 + 3
	mid_layer.add_child(fascia)
	# fascia highlight strip
	var strip := ColorRect.new()
	strip.position = Vector2(x, y + 22)
	strip.size = Vector2(w, 4)
	strip.color = trim.lightened(0.15)
	strip.z_index = z0 + 4
	mid_layer.add_child(strip)

	# upper windows with frames + optional shutters (above awning)
	var win_cols := 3 if w > 200 else 2
	for col in win_cols:
		var wx := x + 24 + col * ((w - 48) / win_cols)
		var wy := y + 34
		_window_unit(wx, wy, 36, 42, z0 + 6, variant + col, true)

	# striped awning canopy — sits below upper windows
	var awn_cols := maxi(int(w / 28.0), 4)
	for ai in awn_cols:
		var awn := ColorRect.new()
		awn.size = Vector2(w / awn_cols + 1, 18)
		awn.position = Vector2(x + ai * (w / awn_cols), y + 82)
		awn.color = trim if ai % 2 == 0 else Color("FBF7EE")
		awn.z_index = z0 + 5
		mid_layer.add_child(awn)
	# awning depth lip
	var lip := ColorRect.new()
	lip.position = Vector2(x - 2, y + 98)
	lip.size = Vector2(w + 4, 5)
	lip.color = Color(0.2, 0.14, 0.1, 0.55)
	lip.z_index = z0 + 5
	mid_layer.add_child(lip)

	# ground-floor: roll shutter OR door + side windows
	if variant % 2 == 0:
		# roll-up shutter bay
		var shutter := ColorRect.new()
		shutter.position = Vector2(x + 28, y + 108)
		shutter.size = Vector2(w - 56, h - 108)
		shutter.color = Color(0.55, 0.58, 0.6)
		shutter.z_index = z0 + 6
		mid_layer.add_child(shutter)
		for ri in range(0, int(h - 108), 10):
			var rib := ColorRect.new()
			rib.position = Vector2(x + 28, y + 108 + ri)
			rib.size = Vector2(w - 56, 2)
			rib.color = Color(0.4, 0.42, 0.45, 0.7)
			rib.z_index = z0 + 7
			mid_layer.add_child(rib)
		# lock bar
		var lock := ColorRect.new()
		lock.position = Vector2(x + w * 0.5 - 10, y + h - 40)
		lock.size = Vector2(20, 8)
		lock.color = Color(0.25, 0.2, 0.15)
		lock.z_index = z0 + 8
		mid_layer.add_child(lock)
	else:
		_window_unit(x + 22, y + 120, 36, 44, z0 + 6, variant, false)
		_window_unit(x + w - 58, y + 120, 36, 44, z0 + 6, variant + 1, false)
		# door with frame behind
		var door_frame := ColorRect.new()
		door_frame.size = Vector2(46, 76)
		door_frame.position = Vector2(x + w * 0.5 - 23, y + h - 74)
		door_frame.color = Color(0.2, 0.12, 0.08)
		door_frame.z_index = z0 + 6
		mid_layer.add_child(door_frame)
		var door := ColorRect.new()
		door.size = Vector2(40, 72)
		door.position = Vector2(x + w * 0.5 - 20, y + h - 72)
		door.color = Color(0.32, 0.2, 0.12)
		door.z_index = z0 + 7
		mid_layer.add_child(door)
		var knob := ColorRect.new()
		knob.size = Vector2(4, 4)
		knob.position = Vector2(x + w * 0.5 + 10, y + h - 40)
		knob.color = Color("F2C230")
		knob.z_index = z0 + 8
		mid_layer.add_child(knob)

	# balcony rail under upper windows on odd variants
	if variant % 2 == 1:
		var rail := ColorRect.new()
		rail.position = Vector2(x + 18, y + 76)
		rail.size = Vector2(w - 36, 4)
		rail.color = Color(0.35, 0.3, 0.25)
		rail.z_index = z0 + 8
		mid_layer.add_child(rail)
		for bi in range(0, int(w - 36), 12):
			var bal := ColorRect.new()
			bal.position = Vector2(x + 18 + bi, y + 68)
			bal.size = Vector2(3, 12)
			bal.color = Color(0.4, 0.35, 0.3)
			bal.z_index = z0 + 8
			mid_layer.add_child(bal)

	# street-level skirting / damp stain
	var skirt := ColorRect.new()
	skirt.position = Vector2(x, y + h - 14)
	skirt.size = Vector2(w, 14)
	skirt.color = wall.darkened(0.22)
	skirt.z_index = z0 + 4
	mid_layer.add_child(skirt)

	# AC box on some façades
	if variant % 3 != 2:
		var ac := ColorRect.new()
		ac.size = Vector2(34, 18)
		ac.position = Vector2(x + w * 0.65, y + 52)
		ac.color = Color(0.78, 0.8, 0.82)
		ac.z_index = z0 + 9
		mid_layer.add_child(ac)
		var ac_vent := ColorRect.new()
		ac_vent.size = Vector2(26, 4)
		ac_vent.position = Vector2(x + w * 0.65 + 4, y + 58)
		ac_vent.color = Color(0.45, 0.48, 0.5)
		ac_vent.z_index = z0 + 10
		mid_layer.add_child(ac_vent)


func _window_unit(x: float, y: float, w: float, h: float, z: int, seed: int, with_shutter: bool) -> void:
	var frame := ColorRect.new()
	frame.position = Vector2(x - 3, y - 3)
	frame.size = Vector2(w + 6, h + 6)
	frame.color = Color(0.25, 0.18, 0.12)
	frame.z_index = z
	mid_layer.add_child(frame)
	var glass := ColorRect.new()
	glass.position = Vector2(x, y)
	glass.size = Vector2(w, h)
	# some lit, some dark
	glass.color = Color(0.55, 0.72, 0.82, 0.75) if seed % 3 != 0 else Color(0.22, 0.28, 0.35, 0.85)
	glass.z_index = z + 1
	mid_layer.add_child(glass)
	# mullion
	var mull := ColorRect.new()
	mull.position = Vector2(x + w * 0.5 - 1, y)
	mull.size = Vector2(2, h)
	mull.color = Color(0.3, 0.22, 0.15)
	mull.z_index = z + 2
	mid_layer.add_child(mull)
	var cross := ColorRect.new()
	cross.position = Vector2(x, y + h * 0.45)
	cross.size = Vector2(w, 2)
	cross.color = Color(0.3, 0.22, 0.15)
	cross.z_index = z + 2
	mid_layer.add_child(cross)
	if with_shutter and seed % 2 == 0:
		var shut := ColorRect.new()
		shut.size = Vector2(w * 0.45, h + 4)
		shut.position = Vector2(x - 2, y - 2)
		shut.color = Color("B23A2E").lightened(0.1) if seed % 3 == 0 else Color("3E6FB0").lightened(0.05)
		shut.z_index = z + 3
		mid_layer.add_child(shut)
		# shutter slats
		for si in range(0, int(h), 6):
			var slat := ColorRect.new()
			slat.position = Vector2(x - 2, y - 2 + si)
			slat.size = Vector2(w * 0.45, 1)
			slat.color = Color(0, 0, 0, 0.2)
			slat.z_index = z + 4
			mid_layer.add_child(slat)


func _shop_block(
	x: float,
	y: float,
	w: float,
	h: float,
	wall: Color,
	trim: Color,
	ta: String = "",
	en: String = "",
) -> void:
	var z0 := int(SIDEWALK_Y) - 10
	var wall_r := ColorRect.new()
	wall_r.position = Vector2(x, y)
	wall_r.size = Vector2(w, h)
	wall_r.color = wall
	wall_r.z_index = z0
	world.add_child(wall_r)

	# side pilasters
	for px in [x, x + w - 12]:
		var pil := ColorRect.new()
		pil.position = Vector2(px, y)
		pil.size = Vector2(12, h)
		pil.color = wall.darkened(0.12)
		pil.z_index = z0 + 1
		world.add_child(pil)

	# roof coping
	var cope := ColorRect.new()
	cope.position = Vector2(x - 6, y - 8)
	cope.size = Vector2(w + 12, 10)
	cope.color = wall.darkened(0.2)
	cope.z_index = z0 + 2
	world.add_child(cope)

	var fascia := ColorRect.new()
	fascia.position = Vector2(x, y)
	fascia.size = Vector2(w, 32)
	fascia.color = trim
	fascia.z_index = z0 + 2
	world.add_child(fascia)
	var fascia_edge := ColorRect.new()
	fascia_edge.position = Vector2(x, y + 28)
	fascia_edge.size = Vector2(w, 4)
	fascia_edge.color = trim.lightened(0.2)
	fascia_edge.z_index = z0 + 3
	world.add_child(fascia_edge)

	# open shop mouth (dark recess) with counter ledge
	var mouth_w := w * 0.72
	var mouth_x := x + (w - mouth_w) * 0.5
	var mouth := ColorRect.new()
	mouth.position = Vector2(mouth_x, y + 70)
	mouth.size = Vector2(mouth_w, h - 70)
	mouth.color = Color(0.15, 0.12, 0.1)
	mouth.z_index = z0 + 3
	world.add_child(mouth)
	# interior back wall hint
	var back := ColorRect.new()
	back.position = Vector2(mouth_x + 10, y + 78)
	back.size = Vector2(mouth_w - 20, h - 110)
	back.color = wall.darkened(0.35)
	back.z_index = z0 + 4
	world.add_child(back)
	# counter
	var counter := ColorRect.new()
	counter.position = Vector2(mouth_x - 4, y + h - 48)
	counter.size = Vector2(mouth_w + 8, 28)
	counter.color = Color("8B5A2B")
	counter.z_index = z0 + 5
	world.add_child(counter)
	var counter_top := ColorRect.new()
	counter_top.position = Vector2(mouth_x - 6, y + h - 52)
	counter_top.size = Vector2(mouth_w + 12, 8)
	counter_top.color = Color("A07040")
	counter_top.z_index = z0 + 6
	world.add_child(counter_top)

	# roll shutter partially up above mouth
	var shutter := ColorRect.new()
	shutter.position = Vector2(mouth_x - 2, y + 36)
	shutter.size = Vector2(mouth_w + 4, 36)
	shutter.color = Color(0.5, 0.52, 0.55)
	shutter.z_index = z0 + 5
	world.add_child(shutter)
	for ri in range(0, 36, 7):
		var rib := ColorRect.new()
		rib.position = Vector2(mouth_x - 2, y + 36 + ri)
		rib.size = Vector2(mouth_w + 4, 2)
		rib.color = Color(0.35, 0.37, 0.4, 0.65)
		rib.z_index = z0 + 6
		world.add_child(rib)

	# striped shade cloth hanging out
	var shade_cols := maxi(int(mouth_w / 22.0), 5)
	for ai in shade_cols:
		var awn := ColorRect.new()
		awn.size = Vector2(mouth_w / shade_cols + 1, 18)
		awn.position = Vector2(mouth_x + ai * (mouth_w / shade_cols), y + 66)
		awn.color = trim.lightened(0.1) if ai % 2 == 0 else Color("FBF7EE")
		awn.z_index = z0 + 7
		world.add_child(awn)

	# side windows flanking
	_shop_window(x + 16, y + 90, 28, 36, z0 + 4)
	_shop_window(x + w - 44, y + 90, 28, 36, z0 + 4)

	# damp skirting
	var skirt := ColorRect.new()
	skirt.position = Vector2(x, y + h - 12)
	skirt.size = Vector2(w, 12)
	skirt.color = wall.darkened(0.25)
	skirt.z_index = z0 + 4
	world.add_child(skirt)

	# hanging wire / bulb stub over mouth
	var bulb_line := ColorRect.new()
	bulb_line.position = Vector2(x + w * 0.5 - 1, y + 55)
	bulb_line.size = Vector2(2, 16)
	bulb_line.color = Color(0.2, 0.15, 0.1)
	bulb_line.z_index = z0 + 8
	world.add_child(bulb_line)
	var bulb := ColorRect.new()
	bulb.position = Vector2(x + w * 0.5 - 5, y + 68)
	bulb.size = Vector2(10, 10)
	bulb.color = Color(0.95, 0.85, 0.45, 0.85)
	bulb.z_index = z0 + 8
	world.add_child(bulb)

	if ta != "":
		_board(x + 8, y - 52, minf(w - 16, 280), 48, Color("FBF7EE"), Color("2B1D14"), ta, en, 0.0)
	# Thin blocker at shop face — walk in front on the road, not through the stall
	_wall(x + w * 0.5, SIDEWALK_Y + 10, w * 0.85, 36)


func _shop_window(x: float, y: float, w: float, h: float, z: int) -> void:
	var frame := ColorRect.new()
	frame.position = Vector2(x - 2, y - 2)
	frame.size = Vector2(w + 4, h + 4)
	frame.color = Color(0.2, 0.14, 0.1)
	frame.z_index = z
	world.add_child(frame)
	var glass := ColorRect.new()
	glass.position = Vector2(x, y)
	glass.size = Vector2(w, h)
	glass.color = Color(0.4, 0.55, 0.65, 0.7)
	glass.z_index = z + 1
	world.add_child(glass)


func _prop_sprite(path: String, feet: Vector2, scale_f: float) -> Node2D:
	var holder := Node2D.new()
	holder.position = feet
	holder.z_index = int(feet.y)
	var s := Sprite2D.new()
	if ResourceLoader.exists(path):
		s.texture = load(path)
	s.scale = Vector2(scale_f, scale_f)
	s.centered = true
	if s.texture:
		s.offset = Vector2(0, -s.texture.get_height() * 0.5)
	holder.add_child(s)
	# Ground shadow
	var sh := Polygon2D.new()
	sh.color = Color(0, 0, 0, 0.18)
	sh.polygon = PackedVector2Array([
		Vector2(-22, -2), Vector2(22, -2), Vector2(16, 8), Vector2(-16, 8)
	])
	holder.add_child(sh)
	world.add_child(holder)
	return holder


func _build_quest_actors() -> void:
	_make_actor("TeaMaster", 1420, "res://art/svg/chars/tea_master.svg", 0.58, "squash", _on_tea_pushed, 770)
	auto_block = _blocker(3080)
	_prop_sprite("res://art/svg/props/auto.svg", Vector2(3080, 830), 1.0)
	_make_actor("AutoDriver", 3220, "res://art/svg/chars/local_yellow.svg", 0.52, "wobble", _on_auto_pushed, 840)
	milk_node = _make_actor("Milk", 3580, "res://art/svg/props/milk_packet.svg", 0.6, "launch", _on_milk_pushed, 870)
	_make_actor("DirectionsMan", 620, "res://art/svg/chars/local_red.svg", 0.52, "wobble", _on_directions, 850)
	coconut = _prop_sprite("res://art/svg/props/coconut_pile.svg", Vector2(3360, 910), 0.45)


func _build_gags() -> void:
	# --- BUS STOP pack ---
	_make_actor("BusLean", 160, "res://art/svg/props/auto.svg", 0.55, "wobble", _on_bus, 830)
	_make_actor("BusBenchCan", 280, "res://art/svg/props/water_pot.svg", 0.34, "wobble", Callable(), 870)
	_make_actor("Poster", 400, "res://art/svg/props/cutout.svg", 0.3, "wobble", _on_poster, 755)
	_make_actor("BusGlasses", 520, "res://art/svg/props/tea_glasses.svg", 0.28, "squash", Callable(), 900)
	_make_actor("Dog", 760, "res://art/svg/props/dog.svg", 0.62, "squash", _on_dog, 920)
	dog = interactables.get_node_or_null("Dog")

	# --- TEA HUB dense pack (1200–1650): overlapping depth, clutter, people ---
	_make_actor("Kolam", 1120, "res://art/svg/props/kolam.svg", 0.34, "squash", _on_kolam, 930)
	_make_actor("Kids", 1180, "res://art/svg/chars/kids.svg", 0.55, "launch", _on_kids, 890)
	_make_actor("Bananas", 1260, "res://art/svg/props/banana_bunch.svg", 0.46, "wobble", _on_bananas, 735)
	_make_actor("Bananas2", 1320, "res://art/svg/props/banana_bunch.svg", 0.32, "wobble", Callable(), 755)
	_make_actor("SteamPot", 1340, "res://art/svg/props/steam_pot.svg", 0.5, "squash", _on_steam, 780)
	_make_actor("WaterCanHub", 1385, "res://art/svg/props/water_pot.svg", 0.38, "wobble", Callable(), 820)
	_make_actor("TeaGlasses", 1470, "res://art/svg/props/tea_glasses.svg", 0.5, "squash", _on_glasses, 805)
	_make_actor("BiscuitJar", 1525, "res://art/svg/props/biscuit_jar.svg", 0.42, "wobble", Callable(), 785)
	_make_actor("GlassesStack", 1560, "res://art/svg/props/tea_glasses.svg", 0.32, "squash", Callable(), 835)
	_make_actor("LocalExtra", 1600, "res://art/svg/chars/local_blue.svg", 0.5, "wobble", Callable(), 845)  # auntie nearer hub
	_make_actor("Radio", 1660, "res://art/svg/props/radio.svg", 0.55, "spin", _on_radio, 800)
	_make_actor("BenchRegular", 1760, "res://art/svg/chars/local_green.svg", 0.52, "wobble", Callable(), 880)
	_add_hub_steam(1400, 720)
	_add_hub_stool(1580, 860)
	_add_hanging_bulbs()

	# --- MID STREET filler (was empty stretch) ---
	_make_actor("WaterPot", 2050, "res://art/svg/props/water_pot.svg", 0.48, "wobble", _on_pot, 880)
	_make_actor("MidBananas", 2180, "res://art/svg/props/banana_bunch.svg", 0.36, "wobble", Callable(), 760)
	_make_actor("Glasses2", 2320, "res://art/svg/props/tea_glasses.svg", 0.36, "squash", _on_glasses, 940)
	_make_actor("MidRadio", 2480, "res://art/svg/props/radio.svg", 0.4, "spin", Callable(), 820)
	_make_actor("Kolam2", 2650, "res://art/svg/props/kolam.svg", 0.3, "squash", _on_kolam, 950)
	_make_actor("MidCan", 2780, "res://art/svg/props/water_pot.svg", 0.32, "wobble", Callable(), 900)

	# --- AUTO STAND pack ---
	_make_actor("Horn", 2980, "res://art/svg/props/horn.svg", 0.48, "wobble", _on_horn, 815)
	_make_actor("Meter", 3120, "res://art/svg/props/auto_meter.svg", 0.45, "fall", _on_meter, 790)
	_make_actor("AutoSpare", 3300, "res://art/svg/props/auto.svg", 0.55, "wobble", Callable(), 860)
	_make_actor("CoconutStall", 3420, "res://art/svg/props/coconut_pile.svg", 0.52, "fall", _on_coconut_stall, 900)
	_make_actor("WaterCanAuto", 3500, "res://art/svg/props/water_pot.svg", 0.36, "wobble", Callable(), 880)
	_make_actor("Cutout", 4000, "res://art/svg/props/cutout.svg", 0.48, "spin", _on_cutout, 780)


func _add_hub_steam(x: float, y: float) -> void:
	## Soft steam puffs above the kadai — registered for idle bob.
	for i in 4:
		var puff := Polygon2D.new()
		puff.color = Color(1, 1, 1, 0.28 - i * 0.04)
		puff.polygon = PackedVector2Array([
			Vector2(-8, 0), Vector2(-2, -14), Vector2(6, -10), Vector2(10, 2), Vector2(0, 6)
		])
		puff.position = Vector2(x + i * 18.0, y - i * 8.0)
		puff.z_index = int(SIDEWALK_Y) + 5
		puff.set_meta("base_y", puff.position.y)
		world.add_child(puff)
		_idle_actors.append({
			"node": puff,
			"base_y": puff.position.y,
			"kind": "wobble",
			"phase": float(i) * 0.9,
		})


func _add_hub_stool(x: float, y: float) -> void:
	var stool := Node2D.new()
	stool.position = Vector2(x, y)
	stool.z_index = int(y)
	var seat := ColorRect.new()
	seat.size = Vector2(36, 10)
	seat.position = Vector2(-18, -40)
	seat.color = Color("8B5A2B")
	stool.add_child(seat)
	for lx in [-12.0, 10.0]:
		var leg := ColorRect.new()
		leg.size = Vector2(5, 32)
		leg.position = Vector2(lx, -32)
		leg.color = Color("5A3A1A")
		stool.add_child(leg)
	var sh := Polygon2D.new()
	sh.color = Color(0, 0, 0, 0.15)
	sh.polygon = PackedVector2Array([Vector2(-16, -2), Vector2(16, -2), Vector2(12, 6), Vector2(-12, 6)])
	stool.add_child(sh)
	world.add_child(stool)


func _add_hanging_bulbs() -> void:
	## Pulsing filament bulbs along the tea-hub eaves.
	for i in 5:
		var bulb := Node2D.new()
		var bx := 1240.0 + i * 70.0
		var by := SIDEWALK_Y - 95.0
		bulb.position = Vector2(bx, by)
		bulb.z_index = int(SIDEWALK_Y) - 2
		var wire := ColorRect.new()
		wire.size = Vector2(2, 18)
		wire.position = Vector2(-1, -18)
		wire.color = Color(0.2, 0.15, 0.1)
		bulb.add_child(wire)
		var glow := ColorRect.new()
		glow.size = Vector2(14, 14)
		glow.position = Vector2(-7, -2)
		glow.color = Color(0.98, 0.88, 0.45, 0.9)
		bulb.add_child(glow)
		world.add_child(bulb)
		_sway_nodes.append(bulb)
		# tag for blink in _process
		bulb.set_meta("blink", true)
		bulb.set_meta("glow", glow)


func _clear_sprites(n: Node) -> void:
	for c in n.get_children():
		if c is Sprite2D:
			c.queue_free()


func _make_person_visual(shirt: Color, skin: Color, scale_f: float) -> Node2D:
	var root := Node2D.new()
	root.scale = Vector2(scale_f, scale_f)
	# shadow
	var sh := Polygon2D.new()
	sh.color = Color(0, 0, 0, 0.2)
	sh.polygon = PackedVector2Array([Vector2(-16, -2), Vector2(16, -2), Vector2(12, 6), Vector2(-12, 6)])
	root.add_child(sh)
	var legs := ColorRect.new()
	legs.size = Vector2(26, 34)
	legs.position = Vector2(-13, -34)
	legs.color = Color(0.22, 0.14, 0.1)
	root.add_child(legs)
	var body := ColorRect.new()
	body.size = Vector2(38, 44)
	body.position = Vector2(-19, -78)
	body.color = shirt
	root.add_child(body)
	var head := ColorRect.new()
	head.size = Vector2(32, 32)
	head.position = Vector2(-16, -110)
	head.color = skin
	root.add_child(head)
	for ex in [-5.0, 5.0]:
		var eye := ColorRect.new()
		eye.size = Vector2(4, 4)
		eye.position = Vector2(ex - 2, -98)
		eye.color = Color("2B1D14")
		root.add_child(eye)
	return root


func _make_actor(
	named: String,
	x: float,
	tex_path: String,
	scale_f: float,
	reaction: String,
	cb: Callable = Callable(),
	y: float = 860.0,
) -> Area2D:
	var area := Area2D.new()
	area.name = named
	area.position = Vector2(x, y)
	area.z_index = int(y)
	area.collision_layer = 8
	area.collision_mask = 0
	area.monitoring = false
	area.monitorable = true
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(64, 64)
	shape.shape = rect
	shape.position = Vector2(0, -28)
	area.add_child(shape)
	if tex_path != "" and ResourceLoader.exists(tex_path):
		var s := Sprite2D.new()
		s.texture = load(tex_path)
		s.scale = Vector2(scale_f, scale_f)
		s.centered = true
		if s.texture:
			s.offset = Vector2(0, -s.texture.get_height() * 0.5)
		area.add_child(s)
	# shadow for sprites
	var sh := Polygon2D.new()
	sh.color = Color(0, 0, 0, 0.18)
	sh.polygon = PackedVector2Array([Vector2(-20, -2), Vector2(20, -2), Vector2(14, 7), Vector2(-14, 7)])
	area.add_child(sh)
	var p := Pushable.new()
	p.reaction = reaction
	p.custom_id = named
	p.sfx_path = "res://audio/sfx/push.wav"
	area.add_child(p)
	if cb.is_valid():
		p.pushed.connect(cb)
	interactables.add_child(area)
	_register_idle(area, named, y, tex_path)
	return area


func _register_idle(area: Node2D, named: String, y: float, tex_path: String) -> void:
	## Tiny loops so the street breathes — kind picked from role name / path.
	var kind := ""
	match named:
		"TeaMaster":
			kind = "pour"
		"DirectionsMan":
			kind = "point"
		"Kids":
			kind = "hop"
		"Dog":
			kind = "pant"
		"Radio", "Horn", "BiscuitJar", "SteamPot":
			kind = "wobble"
		"BenchRegular", "LocalExtra", "AutoDriver":
			kind = "breathe"
		_:
			if tex_path.contains("/chars/"):
				kind = "breathe"
	if kind == "":
		return
	_idle_actors.append({
		"node": area,
		"base_y": y,
		"kind": kind,
		"phase": float(_idle_actors.size()) * 1.3,
	})


func _blocker(x: float) -> StaticBody2D:
	var body := StaticBody2D.new()
	body.name = "AutoBlock"
	body.position = Vector2(x, 830)
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(150, 100)
	shape.shape = rect
	body.add_child(shape)
	world.add_child(body)
	return body


func _on_line(_npc: String, line: Dictionary) -> void:
	bubble.text = str(line.get("ta", ""))
	subtitle.text = str(line.get("en_subtitle", ""))
	bubble.visible = true
	subtitle.visible = true
	var bp := $UI.get_node_or_null("BubblePlate")
	var sp := $UI.get_node_or_null("SubPlate")
	if bp:
		bp.visible = true
	if sp:
		sp.visible = true
	# Pop-in juice
	bubble.scale = Vector2(0.85, 0.85)
	bubble.modulate.a = 0.0
	var pop := create_tween()
	pop.tween_property(bubble, "modulate:a", 1.0, 0.08)
	pop.parallel().tween_property(bubble, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	if _line_tween and is_instance_valid(_line_tween):
		_line_tween.kill()
	_line_tween = create_tween()
	_line_tween.tween_interval(2.4 / maxf(GameState.text_speed, 0.25))
	_line_tween.tween_callback(func() -> void:
		bubble.visible = false
		subtitle.visible = false
		if bp:
			bp.visible = false
		if sp:
			sp.visible = false
	)


func _on_flag(flag_name: String, value: Variant) -> void:
	if value:
		_update_blockers()
	if flag_name == "tea_done" and value:
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://scenes/ui/end_card.tscn")


func _update_blockers() -> void:
	if auto_block:
		auto_block.set_collision_layer_value(1, not GameState.get_flag("auto_moved"))


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
			tw.parallel().tween_property(coconut, "position:x", coconut.position.x + 900, 1.1)


func _on_milk_pushed(_dir: Vector2, _count: int) -> void:
	if GameState.get_flag("auto_moved") and not GameState.get_flag("has_milk"):
		GameState.set_flag("has_milk", true)
		milk_node.visible = false
		for c in milk_node.get_children():
			if c is CollisionShape2D:
				c.set_deferred("disabled", true)
		subtitle.text = "Acquired: white packet (milk, allegedly)"
		var sp := $UI.get_node_or_null("SubPlate")
		if sp:
			sp.visible = true
		subtitle.visible = true
		_update_blockers()


func _on_directions(_d: Vector2, _c: int) -> void:
	Dialogue.speak("directions_man")


func _on_bananas(_d: Vector2, c: int) -> void:
	if c == 1:
		subtitle.text = "Banana freefall. Crow already budgeting."
		AudioBus.play_sfx("res://audio/sfx/crow.wav")


func _on_glasses(_d: Vector2, c: int) -> void:
	var path := "res://audio/sfx/clink.wav"
	if c % 3 == 2:
		path = "res://audio/sfx/clink2.wav"
	elif c % 3 == 0:
		path = "res://audio/sfx/clink3.wav"
	AudioBus.play_sfx(path)


func _on_radio(_d: Vector2, c: int) -> void:
	AudioBus.play_sfx("res://audio/sfx/jingle%d.wav" % wrapi(c, 1, 4))


func _on_horn(_d: Vector2, _c: int) -> void:
	AudioBus.play_sfx("res://audio/sfx/horn.wav")


func _on_kolam(_d: Vector2, _c: int) -> void:
	Dialogue.speak("kolam_lady", "smudge")


func _on_pot(_d: Vector2, c: int) -> void:
	if c >= 3:
		subtitle.text = "Pot finally dramatic."


func _on_poster(_d: Vector2, c: int) -> void:
	subtitle.text = "Poster peel #%d — identical underneath." % c


func _on_cutout(_d: Vector2, _c: int) -> void:
	subtitle.text = "Cutout rotated 2°. Fans gasp (internally)."


func _on_dog(_d: Vector2, _c: int) -> void:
	GameState.set_flag("dog_following", true)
	subtitle.text = "Dog: employment acquired."


func _on_kids(_d: Vector2, _c: int) -> void:
	player.velocity = Vector2(-player.facing * 320, 40)
	AudioBus.play_beep(1.4)
	subtitle.text = "Kids pushed back. Robot indignant."


func _on_meter(_d: Vector2, _c: int) -> void:
	subtitle.text = "Meter fell off. As designed."


func _on_coconut_stall(_d: Vector2, _c: int) -> void:
	if coconut:
		var tw := create_tween()
		tw.tween_property(coconut, "position:x", coconut.position.x + 700, 1.0)


func _on_bus(_d: Vector2, c: int) -> void:
	if c == 1:
		Dialogue.speak("bus_conductor", "eject")
	else:
		subtitle.text = "Bus lean: %d° of optimism." % (c * 3)
		subtitle.visible = true
		var sp := $UI.get_node_or_null("SubPlate")
		if sp:
			sp.visible = true


func _on_steam(_d: Vector2, _c: int) -> void:
	var heat := player.get_node_or_null("HeatBody")
	if heat:
		heat.set_in_sun(false)
		await get_tree().create_timer(2.0).timeout
		heat.set_in_sun(true)
