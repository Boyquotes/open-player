extends Resource
class_name Profile

signal theme_changed
signal volume_changed(volume)

export var theme: Theme = preload("res://app/themes/dark.tres") setget _set_theme
func _set_theme(value: Theme) -> void:
	theme = value
	emit_changed()
	emit_signal("theme_changed")

export var animations_enabled := true setget _set_animations_enabled
func _set_animations_enabled(value: bool) -> void:
	animations_enabled = value
	emit_changed()

export var animation_speed := 1.0 setget _set_animation_speed
func _set_animation_speed(value: float) -> void:
	animation_speed = value
	emit_changed()

export var language: String = OS.get_locale() setget _set_language
func _set_language(value: String) -> void:
	language = value
	TranslationServer.set_locale(language)
	Global.debug("Changed language to '%s'." % language)
	emit_changed()

export var vibrate_on_touch := true setget _set_vibrate_on_touch
func _set_vibrate_on_touch(value: bool) -> void:
	vibrate_on_touch = value
	emit_changed()

export var discord_rich_presence := true setget _set_discord_rich_presence
func _set_discord_rich_presence(value: bool) -> void:
	discord_rich_presence = value
	emit_changed()

export var tracks: Resource setget _set_tracks
func _set_tracks(value: MyTracks) -> void:
	if tracks != null:
		tracks.disconnect("removed", self, "_on_removed")
	
	tracks = value
	
	if tracks != null:
		Global.ok(tracks.connect("removed", self, "_on_removed"))

func _on_removed(entry: MyTracks.Entry) -> void:
	entry.value.source.delete()
	
	for folder in folders.iter():
		var i: int = folder.find(entry.value)
		if i >= 0:
			folder.remove(i)

export var folders: Resource = List.new()

export var volume := 1.0 setget _set_volume
func _set_volume(value: float) -> void:
	volume = value
	emit_signal("volume_changed", volume)
	emit_changed()

func _init():
	self.tracks = MyTracks.new()
