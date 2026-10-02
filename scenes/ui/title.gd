extends Control


func _ready() -> void:
	var hand = load("res://fonts/PatrickHand-Regular.ttf")
	var tamil = load("res://fonts/NotoSansTamil-Regular.ttf")
	var bold = load("res://fonts/NotoSansTamil-Bold.ttf")
	if hand:
		$TitleLabel.add_theme_font_override("font", hand)
		$Sub.add_theme_font_override("font", hand)
		$Prompt.add_theme_font_override("font", hand)
	if tamil and has_node("TamilLine"):
		$TamilLine.add_theme_font_override("font", tamil)
	if bold:
		$TitleLabel.add_theme_font_override("font", bold)
	# Soft entrance
	$TitleLabel.modulate.a = 0.0
	$Robot.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property($TitleLabel, "modulate:a", 1.0, 0.4)
	tw.parallel().tween_property($Robot, "modulate:a", 1.0, 0.5)
	# Blink start prompt
	var blink := create_tween().set_loops()
	blink.tween_property($Prompt, "modulate:a", 0.35, 0.7)
	blink.tween_property($Prompt, "modulate:a", 1.0, 0.7)
	# Idle robot bob
	var bob := create_tween().set_loops()
	var base_y := $Robot.position.y
	bob.tween_property($Robot, "position:y", base_y - 10.0, 0.9).set_trans(Tween.TRANS_SINE)
	bob.tween_property($Robot, "position:y", base_y, 0.9).set_trans(Tween.TRANS_SINE)
	if ResourceLoader.exists("res://audio/sfx/jingle1.wav"):
		AudioBus.play_sfx("res://audio/sfx/jingle1.wav", "SFX", 1.0, -6.0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") or event.is_action_pressed("push"):
		get_tree().change_scene_to_file("res://scenes/levels/george_street.tscn")
