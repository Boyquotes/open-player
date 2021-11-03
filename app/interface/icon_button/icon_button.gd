tool
extends Button
class_name IconButton, "res://app/interface/icon_button/icon_button.svg"

onready var hint := Hint.new()

func _init():
	### PROPERTIES ###
	
	clip_text = true
	mouse_default_cursor_shape = CURSOR_POINTING_HAND
	
	### STYLE ###
	
	var style := StyleBoxEmpty.new()
	style.content_margin_top = 4.0
	style.content_margin_bottom = 4.0
	style.content_margin_left = 4.0
	style.content_margin_right = 4.0
	
	add_constant_override("hseparation", 0)
	add_stylebox_override("normal", style)
	add_stylebox_override("hover", style)
	add_stylebox_override("pressed", style)

func _set(name: String, value):
	if name == "text":
		text = value
		
		if is_inside_tree():
			_update_text()

func _ready() -> void:
	_update_text()
	
	### SCENE ###
	
	hint.set_anchors_and_margins_preset(PRESET_WIDE)
	add_child(hint)
	
	### SIGNALS ###
	
	_update_style()
	Global.ok(Global.profile.connect("theme_changed", self, "_update_style"))

func _update_text() -> void:
	hint.text = text
	hint.visible = not text.empty()

func _update_style() -> void:
	if not Engine.editor_hint:
		modulate = get_color("icon")
