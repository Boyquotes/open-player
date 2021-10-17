extends HBoxContainer

onready var home_button := $Home
onready var import_button := $Import
onready var tracks_button := $Tracks
onready var folders_button := $Folders
onready var settings_button := $Settings

func _ready() -> void:
	_update_active_view(Global.player.active_view)
	Global.ok(Global.player.connect("active_view_changed", self, "_update_active_view"))

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("search"):
		Global.player.active_view = "import"

func _update_active_view(view) -> void:
	home_button.selected = false
	import_button.selected = false
	tracks_button.selected = false
	folders_button.selected = false
	settings_button.selected = false
	
	match view:
		"home":
			home_button.selected = true
		"import":
			import_button.selected = true
		"tracks":
			tracks_button.selected = true
		"folders":
			folders_button.selected = true
		"settings":
			settings_button.selected = true

func _on_Home_pressed() -> void:
	Global.player.active_view = "home"

func _on_Import_pressed() -> void:
	Global.player.active_view = "import"

func _on_Tracks_pressed() -> void:
	Global.player.active_view = "tracks"

func _on_Folders_pressed() -> void:
	Global.player.active_view = "folders"

func _on_Settings_pressed() -> void:
	Global.player.active_view = "settings"
