extends "res://app/modules/playable_track_list/playable_track_list.gd"

func _ready() -> void:
	self.list = Global.profile.tracks
