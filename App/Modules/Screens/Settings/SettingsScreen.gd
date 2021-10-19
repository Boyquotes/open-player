extends ScrollContainer

onready var language_option := $VBoxContainer/Language

onready var theme_option := $VBoxContainer/Theme

func _ready() -> void:
	update_config()
	Global.ok(Global.profile.connect("changed", self, "update_config"))
	
	### LOCALES ###
	
	var locales := TranslationServer.get_loaded_locales()
	locales.sort()
	locales.erase("en_US")
	locales.push_front("en_US")
	for item in locales:
		var id: int = language_option.get_item_count()
		language_option.add_item(TranslationServer.get_locale_name(item), id)
		language_option.set_item_metadata(id, item)
	
	### THEMES ###
	
	var themes := [
		preload("res://App/Themes/light.tres"),
		preload("res://App/Themes/dark.tres"),
		preload("res://App/Themes/gruvbox.tres")
	]
	for item in themes:
		var id: int = theme_option.get_item_count()
		theme_option.add_item(item.get_meta("name"), id)
		theme_option.set_item_metadata(id, item)

func update_config() -> void:
	$VBoxContainer/Animations/VBoxContainer/AnimationsEnabled.pressed = Global.profile.animations_enabled
	$VBoxContainer/Animations/VBoxContainer/AnimationSpeed.visible = Global.profile.animations_enabled
	$VBoxContainer/Animations/VBoxContainer/AnimationSpeed/HSlider.value = Global.profile.animation_speed
	$VBoxContainer/DiscordRichPresence.visible = Engine.has_singleton("Godotcord")
	$VBoxContainer/DiscordRichPresence.pressed = Global.profile.discord_rich_presence
	
	for i in language_option.get_item_count():
		if language_option.get_item_metadata(i) == Global.profile.language:
			language_option.selected = i
			language_option.text = tr("SETTINGS_LANGUAGE").format([TranslationServer.get_locale_name(Global.profile.language)])
	
	for i in theme_option.get_item_count():
		if theme_option.get_item_metadata(i) == Global.profile.theme:
			theme_option.selected = i
			theme_option.text = tr("SETTINGS_THEME").format([Global.profile.theme.get_meta("name")])

func _on_AnimationsEnabled_toggled(value: bool) -> void:
	Global.profile.animations_enabled = value
	if not Global.profile.animations_enabled:
		Global.profile.animation_speed = 1.0

func _on_AnimationSpeed_value_changed(value: float) -> void:
	Global.profile.animation_speed = value

func _on_Language_item_selected(index: int) -> void:
	Global.profile.language = language_option.get_item_metadata(index)

func _on_Theme_item_selected(index: int) -> void:
	Global.profile.theme = theme_option.get_item_metadata(index)

func _on_DiscordRichPresence_toggled(value: bool) -> void:
	Global.profile.discord_rich_presence = value
