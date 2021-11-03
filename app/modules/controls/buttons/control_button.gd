tool
extends IconButton

export(String, "", "previous_track", "next_track", "seek_back", "seek_forward") var operation: String

func _ready() -> void:
	Global.ok(connect("pressed", self, "_on_pressed"))

func _on_pressed() -> void:
	match operation:
		"previous_track":
			Global.player.previous_track()
		"next_track":
			Global.player.next_track(true)
		"seek_back":
			Global.player.position -= 5.0
		"seek_forward":
			Global.player.position += 5.0
