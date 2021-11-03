extends DummyContainer

onready var title := $VBoxContainer/Title
onready var view := $VBoxContainer/FoldersView
onready var empty := view.get_node("Empty")
onready var current_container := $FolderContainer
onready var current := current_container.get_node("PlayableTrackList")
onready var remove_dialog := $RemoveDialog

var current_folder: List.Entry

func _update_empty() -> void:
	empty.visible = Global.profile.folders.empty()

func _update_style() -> void:
	title.add_font_override("font", title.get_font("list_title"))

func _update_locale() -> void:
	remove_dialog.window_title = tr("GENERIC_CONFIRM_DIALOG")

func _ready() -> void:
	view.list = Global.profile.folders
	
	_update_empty()
	Global.ok(Global.profile.folders.connect("inserted", self, "_on_folder_inserted"))
	Global.ok(Global.profile.folders.connect("removed", self, "_on_folder_removed"))
	
	_update_style()
	Global.ok(Global.profile.connect("theme_changed", self, "_update_style"))
	
	_update_locale()
	
	Global.ok(Global.connect("go_back", self, "_on_go_back"))

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_TRANSLATION_CHANGED:
			_update_locale()

func _on_go_back(request: Global.GoBackRequest) -> void:
	if current_container.showing:
		current_container.showing = false
		request.exit = false

func _on_folder_inserted(_folder: List.Entry) -> void:
	_update_empty()

func _on_folder_removed(folder: List.Entry) -> void:
	if current_folder == folder:
		close()
	_update_empty()

func _on_Add_pressed() -> void:
	var index: int = Global.profile.folders.size()
	var number := index + 1
	var folder := Folder.new(tr("FOLDER_DEFAULT_NAME").format([number]))
	Global.profile.folders.add(folder)
	open(Global.profile.folders.entry(index))

func _on_Drop_pressed() -> void:
	close()

func _on_Remove_pressed() -> void:
	remove_dialog.popup_centered_minsize()

func _on_RemoveDialog_confirmed() -> void:
	Global.profile.folders.remove(current_folder.index)

func _on_FoldersScreen_visibility_changed() -> void:
	if not is_visible_in_tree():
		close()

func open(folder: List.Entry) -> void:
	current_folder = folder
	current_container.showing = true
	current.list = folder.value

func close() -> void:
	current_folder = null
	current_container.showing = false
