extends DropContainer

onready var view := $VBoxContainer/TrackListView

func _ready() -> void:
	reset()

func _exit_tree() -> void:
	reset()

func reset() -> void:
	if view.list != null:
		for track in view.list.iter():
			if Global.profile.tracks.has(track):
				continue
			track.source.delete()
	
	view.list = List.new()

func _on_FilesContainer_visibility_changed() -> void:
	reset()
