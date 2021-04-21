extends DummyContainer

const BASE_RESOLUTION := 960.0

func _ready() -> void:
	var safe_area := OS.get_window_safe_area().clip(get_viewport_rect())
	
	margin_left = safe_area.position.x
	margin_right = safe_area.end.x - get_viewport_rect().size.x
	margin_top = safe_area.position.y
	margin_bottom = safe_area.end.y - get_viewport_rect().size.y
	
	_on_resized()
	Global.ok(connect("resized", self, "_on_resized"))

func _on_resized() -> void:
	var size := get_viewport().size / Vector2(720.0, 1280.0)
	var power := 2.0
	var step := 1.0
	
	var ratio := get_viewport().size.aspect()
	if ratio < 1.1:
		self.layout_scene = preload("res://App/Layouts/Portrait.tscn")
		step = pow(power, ceil(log(size.x) / log(power)))
	else:
		self.layout_scene = preload("res://App/Layouts/Landscape.tscn")
		step = pow(power, ceil(log(size.y) / log(power)))
	
	get_tree().set_screen_stretch(
		SceneTree.STRETCH_MODE_2D,
		SceneTree.STRETCH_ASPECT_EXPAND,
		get_viewport().size / step,
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
