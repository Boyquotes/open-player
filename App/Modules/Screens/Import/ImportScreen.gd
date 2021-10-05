extends DummyContainer

onready var files_container := $FilesContainer
onready var files_dialog := $Files/FileDialog
onready var files_loading := $FilesLoading

onready var search_container := $SearchContainer

func _ready() -> void:
	Global.ok(Global.connect("go_back", self, "_on_go_back"))

func _on_go_back(request: Global.GoBackRequest) -> void:
	if files_container.showing:
		files_container.showing = false
		request.exit = false
	elif search_container.showing:
		search_container.showing = false
		request.exit = false

### FILES ###

func _on_FilesButton_pressed() -> void:
	files_container.reset()
	files_container.showing = true

func _on_Import_pressed() -> void:
	files_dialog.popup_centered_clamped(Vector2(800, 500))

func _on_FileDialog_dir_selected(original_path: String) -> void:
	files_loading.visible = true
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	
	var current := [original_path]
	var next: Array
	var dir := Directory.new()
	while not current.empty():
		next = []
		
		for path in current:
			Global.ok(dir.open(path))
			Global.ok(dir.list_dir_begin(true, true))
			while true:
				var p := dir.get_next()
				if p.empty():
					break
				var full_path := dir.get_current_dir() + "/" + p
				if dir.current_is_dir():
					next.push_back(full_path)
				else:
					var track := Track.create_file(full_path)
					if track != null:
						files_container.view.list.add(track)
			dir.list_dir_end()
		
		current = next
	
	files_loading.visible = false

func _on_FileDialog_file_selected(path: String) -> void:
	var track := Track.create_file(path)
	if track != null:
		files_container.view.list.add(track)

func _on_FilesDrop_pressed():
	files_container.showing = false

### SEARCH ###

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("search"):
		search_container.showing = true

func _on_SearchButton_pressed() -> void:
	search_container.showing = true

func _on_SearchDrop_pressed() -> void:
	search_container.showing = false

### GENERAL ###

func _on_ImportScreen_visibility_changed() -> void:
	if not visible:
		files_container.showing = false
		search_container.showing = false
