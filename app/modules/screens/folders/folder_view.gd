extends PanelContainer

signal selected

onready var button: Button = $Button

var entry: List.Entry setget _set_entry
func _set_entry(value: List.Entry) -> void:
	if entry != null:
		entry.value.disconnect("changed", self, "_update_folder")
	
	entry = value
	
	if not is_inside_tree():
		yield(self, "ready")
	
	_update_folder()
	entry.value.connect("changed", self, "_update_folder")

func _update_folder() -> void:
	button.text = entry.value.title

func _update_style() -> void:
	var style := get_stylebox("folder")
	button.add_stylebox_override("normal", style)
	button.add_stylebox_override("pressed", style)
	button.add_stylebox_override("hover", style)
	
	button.add_font_override("font", get_font("folder"))

func _ready() -> void:
	_update_style()
	Global.ok(Global.profile.connect("theme_changed", self, "_update_style"))

var _selecting_jobs := {}

func _select_start(index: int, position: Vector2) -> void:
	_selecting_jobs[index] = get_global_transform().xform(position)

func _select_end(index: int) -> void:
	if _selecting_jobs.erase(index):
		emit_signal("selected")

func _select_update(index: int, position: Vector2) -> void:
	var start_pos = _selecting_jobs.get(index)
	if start_pos != null:
		var global_pos: Vector2 = get_global_transform().xform(position)
		
		if global_pos.distance_squared_to(start_pos) >= Global.CLICK_DRAG_MARGIN_SQ:
			Global.yes(_selecting_jobs.erase(index))
		elif not get_global_rect().has_point(global_pos):
			Global.yes(_selecting_jobs.erase(index))

var _touch_timers := {}

func _on_FolderView_gui_input(event: InputEvent) -> void:
	if OS.has_touchscreen_ui_hint():
		if event is InputEventScreenTouch:
			if event.pressed:
				_select_start(event.index, event.position)
			else:
				_select_end(event.index)
		
		if event is InputEventScreenDrag:
			_select_update(event.index, event.position)
	else:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if event.pressed:
					_select_start(-1, event.position)
				else:
					_select_end(-1)
		if event is InputEventMouseMotion:
			if event.button_mask & BUTTON_MASK_LEFT:
				_select_update(-1, event.position)

func _on_Button_pressed() -> void:
	button.pressed = false
	
	# HACK: If we are re-ordering the list view, ignore the button press.
	if not is_visible_in_tree():
		return
	
	emit_signal("selected")
