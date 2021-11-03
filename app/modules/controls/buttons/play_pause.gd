tool
extends IconButton

func _ready() -> void:
	_on_state_changed(Global.player.playing)
	Global.ok(Global.player.connect("state_changed", self, "_on_state_changed"))
	
	Global.ok(connect("pressed", self, "_on_pressed"))

func _on_state_changed(playing: bool) -> void:
	if playing:
		icon = preload("res://app/icons/control_pause.svg")
		text = "CONTROL_PAUSE"
	else:
		icon = preload("res://app/icons/control_play.svg")
		text = "CONTROL_PLAY"

func _on_pressed() -> void:
	Global.player.toggle_playing()
