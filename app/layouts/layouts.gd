extends DummyContainer

func _ready() -> void:
	var safe_area := OS.get_window_safe_area().clip(get_viewport_rect())
	
	margin_left = safe_area.position.x
	margin_right = safe_area.end.x - get_viewport_rect().size.x
	margin_top = safe_area.position.y
	margin_bottom = safe_area.end.y - get_viewport_rect().size.y
	
	_on_resized()
	Global.ok(connect("resized", self, "_on_resized"))

func _square_round(value: float) -> float:
	return pow(2.0, round(log(value) / log(2.0)))

func _on_resized() -> void:
	var size := get_viewport().size
	var step := 1.0
	
	var ratio := size.aspect()
	if ratio < 1.0:
		self.layout_scene = preload("res://app/layouts/portrait.tscn")
		step = _square_round(move_toward(size.x / 960.0, 2.0, 0.6))
	else:
		self.layout_scene = preload("res://app/layouts/landscape.tscn")
		step = _square_round(move_toward(size.y / 800.0, 1.0, 0.2))
	
	get_tree().set_screen_stretch(
		SceneTree.STRETCH_MODE_2D,
		SceneTree.STRETCH_ASPECT_EXPAND,
		size / step,
		1.0
	)

var layout_suspended := false setget _set_layout_suspended
func _set_layout_suspended(value: bool) -> void:
	if layout_suspended == value:
		return
	
	layout_suspended = value
	
	_update_layout()

var layout_scene: PackedScene setget _set_layout_scene
func _set_layout_scene(value: PackedScene) -> void:
	if layout_scene == value:
		return
	
	layout_scene = value
	
	_update_layout()

var _layout_instance: Node
func _update_layout() -> void:
	if _layout_instance != null:
		remove_child(_layout_instance)
		_layout_instance.queue_free()
		_layout_instance = null
	
	if not layout_suspended:
		if layout_scene != null:
			_layout_instance = layout_scene.instance()
			add_child(_layout_instance)

#func _notification(what: int) -> void:
#	match what:
#		NOTIFICATION_WM_FOCUS_IN:
#			set_deferred("layout_suspended", false)
#		NOTIFICATION_WM_FOCUS_OUT:
#			set_deferred("layout_suspended", true)
