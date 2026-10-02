extends Control


func _ready() -> void:
	var hand = load("res://fonts/PatrickHand-Regular.ttf")
	var tamil = load("res://fonts/NotoSansTamil-Regular.ttf")
	if hand:
		$Title.add_theme_font_override("font", hand)
		$Body.add_theme_font_override("font", hand)
		if has_node("Prompt"):
			$Prompt.add_theme_font_override("font", hand)
	if tamil and has_node("TamilCredit"):
		$TamilCredit.add_theme_font_override("font", tamil)
	var body: Label = $Body
	if OS.has_feature("demo"):
		body.text = "Wishlist Madraspuram"
	else:
		body.text = "To be continued…\n(Office is that way. சார் லஞ்சுக்கு.)"
	modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.5)
	if has_node("Prompt"):
		var blink := create_tween().set_loops()
		blink.tween_property($Prompt, "modulate:a", 0.4, 0.8)
		blink.tween_property($Prompt, "modulate:a", 1.0, 0.8)
	if ResourceLoader.exists("res://audio/sfx/jingle3.wav"):
		AudioBus.play_sfx("res://audio/sfx/jingle3.wav", "SFX", 1.0, -4.0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") or event.is_action_pressed("push"):
		get_tree().change_scene_to_file("res://scenes/ui/title.tscn")
