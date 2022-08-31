tool
extends DummyContainer

onready var logo := $OpenPlayer
onready var current_texture := $AspectRatioContainer/CropEdges/TextureRect as TextureRect

var current: TrackList.Entry setget _set_current
func _set_current(value: TrackList.Entry) -> void:
	if current != null:
		current.value.disconnect("changed", self, "_update_track")
	
	current = value
	
	if current != null:
		Global.ok(current.value.connect("changed", self, "_update_track"))
	
	_update_track()

func _update_style() -> void:
	logo.modulate = get_color("icon")

func _update_track() -> void:
	logo.visible = current == null
	current_texture.visible = current != null
	
	if current != null:
		var texture = current.value.get_texture()
		if texture is GDScriptFunctionState:
			texture = yield(texture, "completed")
		current_texture.texture = texture

func _ready() -> void:
	_update_style()
	Global.ok(Global.profile.connect("theme_changed", self, "_update_style"))
	
	self.current = Global.player.current
	Global.ok(Global.player.connect("track_changed", self, "_set_current"))
