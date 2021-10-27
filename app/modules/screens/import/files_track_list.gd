extends "res://app/modules/playable_track_list/playable_track_list.gd"

func _update_title() -> void:
	title.text = tr("IMPORT_TRACKS_TITLE")
	title.editable = false
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
