extends Control
class_name Hint, "res://app/interface/hint/hint.svg"

const FADE_TIME := 0.1
const SCREEN_EDGE_MARGIN := 8.0
const VERTICAL_DISTANCE := 16.0

export var text := "Hint Text" setget _set_text
func _set_text(value: String) -> void:
	text = value
	
	if not is_inside_tree():
		return
	
	_update_transform()

onready var anchor := Control.new()
onready var label := Label.new()
onready var pointer := TextureRect.new()
onready var tween := Tween.new()

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_PASS
	
	### SCENE ###
	
	var canvas_layer := CanvasLayer.new()
	add_child(canvas_layer)
	
	anchor.rect_size = Vector2.ZERO
	anchor.modulate.a = 0.0
	anchor.theme = preload("res://app/themes/dark.tres")
	canvas_layer.add_child(anchor)
	
	anchor.add_child(label)
	
	pointer.texture = preload("res://app/icons/generic_pointer.svg")
	anchor.add_child(pointer)
	
	add_child(tween)
	
	### STYLE ###
	
	_update_style()
	Global.ok(Global.profile.connect("theme_changed", self, "_update_style"))
	
	### TRANSFORMS ###
	
	_update_transform()
	set_notify_transform(true)
	
	### SHOWING ###
	
	Global.ok(connect("mouse_entered", self, "_on_mouse_entered"))
	Global.ok(connect("mouse_exited", self, "_on_mouse_exited"))
	Global.ok(connect("visibility_changed", self, "_on_visibility_changed"))

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_MOUSE_ENTER:
			if get_rect().has_point(get_local_mouse_position()):
				_set_showing(true)
		NOTIFICATION_WM_MOUSE_EXIT:
			_set_showing(false)
		NOTIFICATION_TRANSFORM_CHANGED:
			_update_transform()

func _update_style() -> void:
	label.add_stylebox_override("normal", get_stylebox("hint"))
	pointer.modulate = get_color("hint")

func _update_transform() -> void:
	label.text = text
	
	var rect := get_global_rect()
	var center := (rect.position.x + rect.end.x) / 2.0
	if rect.position.y - label.rect_size.y - VERTICAL_DISTANCE < SCREEN_EDGE_MARGIN:
		anchor.rect_position = Vector2(center, rect.end.y + VERTICAL_DISTANCE)
		label.set_margins_preset(PRESET_CENTER_TOP)
		pointer.flip_v = true
		pointer.set_margins_preset(PRESET_CENTER_BOTTOM)
	else:
		anchor.rect_position = Vector2(center, rect.position.y - VERTICAL_DISTANCE)
		label.set_margins_preset(PRESET_CENTER_BOTTOM)
		pointer.flip_v = false
		pointer.set_margins_preset(PRESET_CENTER_TOP)
	
	var min_x := SCREEN_EDGE_MARGIN
	var max_x := get_viewport_rect().size.x - label.rect_size.x - SCREEN_EDGE_MARGIN
	label.rect_global_position.x = clamp(label.rect_global_position.x, min_x, max_x)

func _on_item_rect_changed() -> void:
	_update_transform()

func _set_showing(showing: bool) -> void:
	var target := 1.0 if showing else 0.0
	if not Engine.editor_hint and Global.profile.animations_enabled:
		var duration := FADE_TIME / Global.profile.animation_speed
		Global.yes(tween.interpolate_property(anchor, "modulate:a", null, target, duration))
		Global.yes(tween.start())
	else:
		anchor.modulate.a = target

func _on_mouse_entered() -> void:
	_set_showing(true)

func _on_mouse_exited() -> void:
	_set_showing(false)

func _on_visibility_changed() -> void:
	if not is_visible_in_tree():
		_set_showing(false)
