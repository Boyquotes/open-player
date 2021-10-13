tool
extends "res://App/Interface/IconButton/IconButton.gd"

func _ready() -> void:
	if Engine.editor_hint:
		_on_state_changed(true)
		return
	
	_on_state_changed(Global.player.playing)
	Global.ok(Global.player.connect("state_changed", self, "_on_state_changed"))

func _on_state_changed(playing: bool) -> void:
	if playing:
		self.texture = preload("res://App/Icons/control_pause.svg")
		self.hint = "CONTROL_PAUSE"
	else:
		self.texture = preload("res://App/Icons/control_play.svg")
		self.hint = "CONTROL_PLAY"

func _pressed() -> void:
	Global.player.toggle_playing()
