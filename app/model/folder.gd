extends TrackList
class_name Folder

export var title: String setget _set_title
func _set_title(value: String) -> void:
	title = value
	
	emit_changed()

func _init(_title := ""):
	title = _title
