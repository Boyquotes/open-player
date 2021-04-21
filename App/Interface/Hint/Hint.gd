extends Control

const HINT_SCREEN_EDGE_MARGIN := 4.0
const HINT_VERTICAL_DISTANCE := 12.0

onready var _is_ready := true
onready var canvas_layer := $CanvasLayer
onready var anchor: Control = canvas_layer.get_node("Anchor")
onready var panel: PanelContainer = anchor.get_node("Panel")
onready var label: Label = panel.get_node("Label")
onready var arrow: Control = anchor.get_node("Arrow")
onready var tween: Tween = $Tween

export var text: String setget _set_text
func _set_text(value: String) -> void:
	text = value
	
	if not is_inside_tree():
		yield(self, "ready")
	
	label.text = text

export var hide_on_release := true

func update_style() -> void:
	label.add_font_override("font", get_font("hint", "Label"))
	
	var color := get_color("hint_color")
	panel.get_stylebox("panel").bg_color = color
	arrow.modulate = color

func _ready() -> void:
	update_style()
	
	set_showing(false)
	
	var node: Node = self
	while node != null and node is Control:
		Global.ok(node.connect("item_rect_changed", self, "update_position"))
		node = node.get_parent()

func _exit_tree() -> void:
	set_showing(false, true)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_MOUSE_EXIT:
			set_showing(false)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if not get_global_rect().has_point(event.position):
			set_showing(false)

func _on_Hint_gui_input(event) -> void:
	if event is InputEventMouse:
		if not text.empty():
			set_showing(true)
	if event is InputEventScreenTouch:
		if not event.pressed:
			if hide_on_release:
				set_showing(false)

func _on_Hint_mouse_exited() -> void:
	set_showing(false)

var _is_showing := false
func set_showing(show: bool, instant := false) -> void:
	var target_color := Color.white if show else Color.transparent
	if instant:
		anchor.modulate = target_color
	elif _is_showing != show:
		Global.yes(tween.interpolate_property(anchor, "modulate", null, target_color, 0.1))
		Global.yes(tween.start())
	
	if show:
		update_position()
	
	_is_showing = show

func update_position() -> void:
	if not is_inside_tree():
		return
	
	var rect := get_global_rect()
	var center := (rect.position.x + rect.end.x) / 2.0
	if rect.position.y - panel.rect_size.y - HINT_VERTICAL_DISTANCE >= HINT_SCREEN_EDGE_MARGIN:
		anchor.rect_position = Vector2(center, rect.position.y - HINT_VERTICAL_DISTANCE)
		panel.set_margins_preset(Control.PRESET_CENTER_BOTTOM)
		arrow.rect_rotation = 0.0
	else:
		anchor.rect_position = Vector2(center, rect.end.y + HINT_VERTICAL_DISTANCE)
		panel.set_margins_preset(Control.PRESET_CENTER_TOP)
		arrow.rect_rotation = 180.0
	
	var min_x := HINT_SCREEN_EDGE_MARGIN
	var max_x := get_viewport_rect().size.x - panel.rect_size.x - HINT_SCREEN_EDGE_MARGIN
	panel.rect_global_position.x = clamp(panel.rect_global_position.x, min_x, max_x)

func _on_Hint_hide() -> void:
	set_showing(false)
