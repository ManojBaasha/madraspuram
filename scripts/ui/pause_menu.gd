extends CanvasLayer

@onready var panel: Control = $Panel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.visible = false
	$Panel/Boil.toggled.connect(_on_boil_toggled)
	$Panel/Speed.value_changed.connect(_on_speed_changed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().paused = not get_tree().paused
		panel.visible = get_tree().paused


func _on_boil_toggled(pressed: bool) -> void:
	GameState.line_boil_enabled = pressed


func _on_speed_changed(value: float) -> void:
	GameState.text_speed = value
