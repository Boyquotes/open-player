extends ScrollContainer

onready var language_option := $VBoxContainer/Language

onready var theme_option := $VBoxContainer/Theme

func _ready() -> void:
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
		preload("res://app/themes/light.tres"),
		preload("res://app/themes/dark.tres"),
		preload("res://app/themes/amoled_black.tres"),
		preload("res://app/themes/gruvbox.tres")
	]
	for item in themes:
		var id: int = theme_option.get_item_count()
		theme_option.add_item(item.get_meta("name"), id)
		theme_option.set_item_metadata(id, item)
	
	### UPDATE CONFIG ###
	
	_update_config()
	Global.ok(Global.profile.connect("changed", self, "_update_config"))
	
	### SHOW VIBRATE ON TOUCH OPTION IF ON MOBILE ###
	
	if OS.get_name() in ["Android", "iOS"]:
		$"VBoxContainer/VibrateOnTouch".visible = true

func _update_config() -> void:
	$VBoxContainer/Animations/VBoxContainer/AnimationsEnabled.pressed = Global.profile.animations_enabled
	$VBoxContainer/Animations/VBoxContainer/AnimationSpeed.visible = Global.profile.animations_enabled
	$VBoxContainer/Animations/VBoxContainer/AnimationSpeed/HSlider.value = Global.profile.animation_speed
	$VBoxContainer/DiscordRichPresence.visible = Global.has_meta("discord_rich_presence_available")
	$VBoxContainer/DiscordRichPresence.pressed = Global.profile.discord_rich_presence
#	$VBoxContainer/VibrateOnTouch.visible = Global.has_meta("discord_rich_presence_available")
	$VBoxContainer/VibrateOnTouch.pressed = Global.profile.vibrate_on_touch
	
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

func _on_VibrateOnTouch_toggled(value: bool) -> void:
	Global.profile.vibrate_on_touch = value

func _on_DiscordRichPresence_toggled(value: bool) -> void:
	Global.profile.discord_rich_presence = value

func _on_DonateButton_pressed() -> void:
	Global.ok(OS.shell_open("https://www.paypal.com/donate?hosted_button_id=JSYDFFV55JZYL"))
