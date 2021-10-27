extends "res://app/interface/track/track_view.gd"
class_name QueueItem

func _ready() -> void:
	Global.ok(Global.player.connect("track_changed", self, "_on_track_changed"))

func _exit_tree() -> void:
	Global.player.disconnect("track_changed", self, "_on_track_changed")

func _on_track_changed(_entry: TrackList.Entry = null) -> void:
	update_active()

func _on_QueueItem_selected() -> void:
	Global.player.current = entry
