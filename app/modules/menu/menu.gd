extends VBoxContainer
class_name Dashboard

onready var home_button := $Home
onready var import_button := $Import
onready var tracks_button := $Tracks
onready var folders_button := $Folders
onready var settings_button := $Settings

onready var buttons := [
	home_button,
	import_button,
	tracks_button,
	folders_button,
	settings_button
]

func _update_style() -> void:
	for button in buttons:
		button.modulate = button.get_color("icon")
		button.add_font_override("font", button.get_font("menu_item"))
		button.add_stylebox_override("normal", button.get_stylebox("menu_button_normal"))
		button.add_stylebox_override("hover", button.get_stylebox("menu_button_hover"))
		button.add_stylebox_override("pressed", button.get_stylebox("menu_button_pressed"))

func _ready() -> void:
	_update_style()
	Global.ok(Global.profile.connect("theme_changed", self, "_update_style"))
	
	_update_active_view(Global.player.active_view)
	Global.ok(Global.player.connect("active_view_changed", self, "_update_active_view"))

func _exit_tree() -> void:
	Global.profile.disconnect("theme_changed", self, "_update_style")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("search"):
		Global.player.active_view = "import"

func _update_active_view(view) -> void:
	match view:
		"home":
			home_button.pressed = true
		"import":
			import_button.pressed = true
		"tracks":
			tracks_button.pressed = true
		"folders":
			folders_button.pressed = true
		"settings":
			settings_button.pressed = true

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
