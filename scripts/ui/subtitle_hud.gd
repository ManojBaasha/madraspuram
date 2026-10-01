extends CanvasLayer
class_name SubtitleHUD

@onready var bubble: Label = $Bubble
@onready var subtitle: Label = $Subtitle


func _ready() -> void:
	Dialogue.line_spoken.connect(_on_line)
	bubble.visible = false
	subtitle.visible = false


func _on_line(_npc: String, line: Dictionary) -> void:
	bubble.text = str(line.get("ta", ""))
	subtitle.text = str(line.get("en_subtitle", ""))
	bubble.visible = true
	subtitle.visible = true
	var hold := 2.4 / maxf(GameState.text_speed, 0.25)
	await get_tree().create_timer(hold).timeout
	# keep last line visible lightly
