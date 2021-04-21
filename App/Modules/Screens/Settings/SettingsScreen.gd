extends MarginContainer

const languages := [
	"en_US", "de_DE", "ru_RU"
]

onready var language := $VBoxContainer/Language

onready var copyright := $Copyright/WindowDialog
onready var copyright_container := copyright.get_node("TabContainer")

func _ready() -> void:
	for code in languages:
		var id: int = language.get_item_count()
		language.add_item(TranslationServer.get_locale_name(code), id)
		language.set_item_metadata(id, code)
	
	for title in Copyright.licenses:
		var label := RichTextLabel.new()
		label.name = title
		label.text = Copyright.licenses[title]
		label.selection_enabled = true
		copyright_container.add_child(label)
	
	update_config()
	Global.ok(Global.profile.connect("changed", self, "update_config"))

func update_config() -> void:
	$VBoxContainer/PanelContainer/VBoxContainer/AnimationsEnabled.pressed = Global.profile.animations_enabled
	$VBoxContainer/PanelContainer/VBoxContainer/AnimationSpeed.visible = Global.profile.animations_enabled
	$VBoxContainer/PanelContainer/VBoxContainer/AnimationSpeed/HSlider.value = Global.profile.animation_speed
	
	for i in language.get_item_count():
		if language.get_item_metadata(i) == Global.profile.language:
			language.selected = i
			language.text = tr("SETTINGS_LANGUAGE").format([TranslationServer.get_locale_name(Global.profile.language)])

func _on_AnimationsEnabled_toggled(button_pressed: bool) -> void:
	Global.profile.animations_enabled = button_pressed
	if not Global.profile.animations_enabled:
		Global.profile.animation_speed = 1.0

func _on_AnimationSpeed_value_changed(value: float) -> void:
	Global.profile.animation_speed = value

func _on_Language_item_selected(index: int) -> void:
	Global.profile.language = language.get_item_metadata(index)

func _on_ShowCopyright_pressed() -> void:
	copyright.popup_centered_clamped(Vector2(700, 400))
