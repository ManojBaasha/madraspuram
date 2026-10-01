extends Node

var _players: Dictionary = {}


func _ready() -> void:
	_ensure_bus("SFX")
	_ensure_bus("Music")
	_ensure_bus("Beeps")


func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) == -1:
		var idx := AudioServer.bus_count
		AudioServer.add_bus()
		AudioServer.set_bus_name(idx, bus_name)


func play_sfx(path: String, bus: String = "SFX", pitch: float = 1.0, volume_db: float = 0.0) -> void:
	if not ResourceLoader.exists(path):
		return
	var stream: AudioStream = load(path)
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.bus = bus
	player.pitch_scale = pitch
	player.volume_db = volume_db
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()


func play_beep(pitch: float = 1.0) -> void:
	play_sfx("res://audio/sfx/beep.wav", "Beeps", pitch)
