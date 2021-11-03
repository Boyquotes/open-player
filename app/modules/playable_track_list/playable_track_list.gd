extends VBoxContainer

var track_scene := preload("res://app/interface/track/track_view.tscn")

onready var title: LineEdit = $Top/Title
onready var view := $Contents/TrackListView
onready var empty := $Contents/Empty

func _update_empty() -> void:
	empty.visible = list.empty()
	if empty.visible:
		if list is MyTracks:
			empty.text = tr("MY_TRACKS_EMPTY")
		elif list is Folder:
			empty.text = tr("FOLDER_EMPTY")

var list: TrackList setget _set_list
func _set_list(value: TrackList) -> void:
	if list != null:
		list.disconnect("inserted", self, "_on_inserted")
		list.disconnect("removed", self, "_on_removed")
	
	list = value
	
	view.list = list
	
	if list != null:
		Global.ok(list.connect("inserted", self, "_on_inserted"))
		Global.ok(list.connect("removed", self, "_on_removed"))
		
		_update_locale()
		_update_empty()

func _update_locale() -> void:
	if list is MyTracks:
		title.text = tr("MY_TRACKS_TITLE")
		title.editable = false
		title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	elif list is Folder:
		title.text = list.title
		title.editable = true
		title.mouse_filter = Control.MOUSE_FILTER_STOP

func _update_style() -> void:
	title.add_font_override("font", title.get_font("list_title"))

func _ready() -> void:
	_update_style()
	Global.ok(Global.profile.connect("theme_changed", self, "_update_style"))

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_TRANSLATION_CHANGED:
			_update_locale()

func _on_inserted(_entry: TrackList.Entry) -> void:
	_update_empty()

func _on_removed(_entry: TrackList.Entry) -> void:
	_update_empty()

func _on_Play_pressed() -> void:
	var tracks := list.contents()
	
	tracks.shuffle()
	for track in tracks:
		Global.player.queue.add(track)

func _on_Title_text_changed(new_text: String) -> void:
	assert(list is Folder)
	
	list.title = new_text

func _on_Title_text_entered(_new_text: String) -> void:
	title.release_focus()

func _on_Title_focus_exited() -> void:
	title.deselect()
