extends DummyContainer

onready var view := $FoldersView
onready var current_container := $FolderContainer
onready var current := $FolderContainer/PlayableTrackList

var entry: List.Entry

func _ready() -> void:
	view.list = Global.profile.folders
	Global.profile.folders.connect("removed", self, "_on_folder_removed")
	
	Global.ok(Global.connect("go_back", self, "_on_go_back"))

func _on_go_back(request: Global.GoBackRequest) -> void:
	if current_container.showing:
		current_container.showing = false
		request.exit = false

func _on_folder_removed(folder: List.Entry) -> void:
	if folder == entry:
		close()

func _on_Add_pressed() -> void:
	var index: int = Global.profile.folders.size()
	var number := index + 1
	var folder := Folder.new(tr("FOLDERS_DEFAULT_NAME").format([number]))
	Global.profile.folders.add(folder)
	open(Global.profile.folders.entry(index))

func _on_Drop_pressed() -> void:
	close()

func _on_FoldersScreen_visibility_changed() -> void:
	if not visible:
		close()

func _on_PlayableTrackList_removed() -> void:
	Global.profile.folders.remove(entry.index)

func open(folder: List.Entry) -> void:
	entry = folder
	current_container.showing = true
	current.list = folder.value

func close() -> void:
	entry = null
	current_container.showing = false
