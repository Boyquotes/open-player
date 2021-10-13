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
	var normal := get_color("icon", "Button")
	var selected := get_color("icon_selected", "Button")
	
	home_button.modulate = normal
	import_button.modulate = normal
	tracks_button.modulate = normal
	folders_button.modulate = normal
	settings_button.modulate = normal
	
	match view:
		"home":
			home_button.pressed = true
			home_button.modulate = selected
		"import":
			import_button.pressed = true
			import_button.modulate = selected
		"tracks":
			tracks_button.pressed = true
			tracks_button.modulate = selected
		"folders":
			folders_button.pressed = true
			folders_button.modulate = selected
		"settings":
			settings_button.pressed = true
			settings_button.modulate = selected

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
