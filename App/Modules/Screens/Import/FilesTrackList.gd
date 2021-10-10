extends "res://App/Modules/PlayableTrackList/PlayableTrackList.gd"

func _update_title() -> void:
	title.text = tr("IMPORT_TRACKS_TITLE")
	title.editable = false
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
