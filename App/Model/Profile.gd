extends Resource
class_name Profile

signal volume_changed(volume)
signal theme_changed(theme)

export var volume := 1.0 setget _set_volume
func _set_volume(value: float) -> void:
	volume = value
	emit_signal("volume_changed", volume)
	emit_changed()

export var tracks: Resource setget _set_tracks
func _set_tracks(value: Tracks) -> void:
	if tracks != null:
		tracks.disconnect("removed", self, "_on_removed")
	
	tracks = value
	
	if tracks != null:
		Global.ok(tracks.connect("removed", self, "_on_removed"))

func _on_removed(entry: Tracks.Entry) -> void:
	entry.value.source.delete()
	
	for folder in folders.iter():
		var i: int = folder.find(entry.value)
		if i >= 0:
			folder.remove(i)

export(Resource) var folders = List.new()

export var animations_enabled := true setget _set_animations_enabled
func _set_animations_enabled(value: bool) -> void:
	animations_enabled = value
	emit_changed()

export var animation_speed := 1.0 setget _set_animation_speed
func _set_animation_speed(value: float) -> void:
	animation_speed = value
	emit_changed()

export var language := "en_US" setget _set_language
func _set_language(value: String) -> void:
	language = value
	TranslationServer.set_locale(language)
	emit_changed()

export var theme: Theme = preload("res://App/Themes/dark.tres") setget _set_theme
func _set_theme(value: Theme) -> void:
	theme = value
	emit_signal("theme_changed", theme)
	emit_changed()

export var discord_rich_presence := true setget _set_discord_rich_presence
func _set_discord_rich_presence(value: bool) -> void:
	discord_rich_presence = value
	emit_changed()

func _init():
	self.tracks = Tracks.new()
