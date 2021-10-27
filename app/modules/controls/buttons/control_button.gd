tool
extends "res://app/interface/icon_button/icon_button.gd"

export(String, "", "previous_track", "next_track", "seek_back", "seek_forward") var operation: String

func _pressed() -> void:
	match operation:
		"previous_track":
			Global.player.previous_track()
		"next_track":
			Global.player.next_track(true)
		"seek_back":
			Global.player.position -= 5.0
		"seek_forward":
			Global.player.position += 5.0
