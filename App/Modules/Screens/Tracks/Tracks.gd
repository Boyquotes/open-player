extends "res://App/Modules/PlayableTrackList/PlayableTrackList.gd"

func _ready() -> void:
	self.list = Global.profile.tracks
