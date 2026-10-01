extends Control


func _ready() -> void:
	var body: Label = $Body
	if OS.has_feature("demo"):
		body.text = "Wishlist Madraspuram"
	else:
		body.text = "To be continued…\n(Office is that way. சார் லஞ்சுக்கு.)"
