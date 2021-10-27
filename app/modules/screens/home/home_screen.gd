tool
extends DummyContainer

onready var logo := $TextureRect

func _update_style() -> void:
	logo.modulate = get_color("icon")

func _ready() -> void:
	_update_style()
	Global.ok(Global.profile.connect("theme_changed", self, "_update_style"))
