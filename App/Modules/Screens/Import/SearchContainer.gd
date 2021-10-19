extends DropContainer

onready var search_box: LineEdit = $VBoxContainer/MarginContainer/HBoxContainer/SearchBox
onready var search_timer: Timer = search_box.get_node("RequestTimer")
onready var view := $VBoxContainer/Results/TrackListView
onready var loading := $VBoxContainer/Results/LoadingContainer/Loading

func update_style() -> void:
	search_box.add_font_override("font", search_box.get_font("search_box"))
	search_box.add_stylebox_override("normal", search_box.get_stylebox("search_box"))

func _ready() -> void:
	update_style()
	Global.ok(Global.connect("theme_changed", self, "update_style"))

func _on_SearchBox_text_changed(_new_text: String) -> void:
	search_timer.start(0.0)

func _on_SearchBox_text_entered(_new_text: String) -> void:
	search_timer.stop()
	_search()

func _get_results() -> Array:
	var search := search_box.text.strip_edges()
	if search.empty():
		return []
	
	var results = yield(YouTube.search(search), "completed")
	
	return results

func _on_RequestTimer_timeout() -> void:
	_search()

func _search() -> void:
	view.list = null
	
	loading.active = true
	var results = _get_results()
	if results is GDScriptFunctionState:
		results = yield(results, "completed")
	loading.active = false
	
	yield(get_tree(), "idle_frame")
	
	var list := TrackList.new()
	
	for from_artist in [true, false]:
		for result in results:
			if result.from_artist == from_artist:
				var track := Track.create_youtube(result)
				var index: int = Global.profile.tracks.find(track)
				if index >= 0:
					track = Global.profile.tracks.at(index)
				
				list.add(track)
	
	view.list = list

func _on_VBoxContainer_visibility_changed() -> void:
	if visible:
		search_box.grab_focus()
