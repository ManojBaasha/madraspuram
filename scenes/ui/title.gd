extends Control


func _ready() -> void:
	var hand = load("res://fonts/PatrickHand-Regular.ttf")
	if hand:
		$TitleLabel.add_theme_font_override("font", hand)
		$Sub.add_theme_font_override("font", hand)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") or event.is_action_pressed("push"):
		get_tree().change_scene_to_file("res://scenes/levels/george_street.tscn")
