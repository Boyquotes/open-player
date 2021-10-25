extends ScrollContainer

const PROPERTY_ENTRY := "entry"
const FADE_TIME := 0.1
const MOVE_TIME := 0.1

export var item_scene: PackedScene
export var editable: bool

export var touch_scroll_curve: Curve
export var touch_scroll_margin := 100.0

onready var container := $Container as Control
onready var tween: Tween = $Tween

var list: List setget _set_list
func _set_list(value: List) -> void:
	if list != null:
		list.disconnect("inserted", self, "_list_inserted")
		list.disconnect("removed", self, "_list_removed")
		list.disconnect("cleared", self, "_list_cleared")
		list.disconnect("ordered", self, "_list_ordered")
	
	for instance in _instances.values():
		_destroy_instance(instance)
	
	_instances.clear()
	
	list = value
	
	if list != null:
		update_container()
		
		Global.ok(list.connect("inserted", self, "_list_inserted"))
		Global.ok(list.connect("removed", self, "_list_removed"))
		Global.ok(list.connect("cleared", self, "_list_cleared"))
		Global.ok(list.connect("ordered", self, "_list_ordered"))

func _ready() -> void:
	set_process(false)
	yield(get_tree(), "idle_frame")
	prepare_instance()
	set_process(true)

func _exit_tree() -> void:
	for instance in _instances.values():
		instance.queue_free()

func _process(delta: float) -> void:
	if list != null:
		_instance_process()
	
	for job in _dragging_jobs.values():
		_drag_update(job, delta)

# --- LIST LOGIC ---

func _list_inserted(entry: List.Entry) -> void:
	update_container()
	
	var temp_instances := {}
	for i in _instances:
		if i >= entry.index:
			temp_instances[i + 1] = _instances[i]
	
	for i in temp_instances:
		_change_index(i, temp_instances[i])
	
	var _flag := _instances.erase(entry.index)

func _list_removed(entry: List.Entry) -> void:
	update_container()
	
	var temp_instances := {}
	for i in _instances.keys():
		if i > entry.index:
			temp_instances[i - 1] = _instances[i]
			Global.yes(_instances.erase(i))
	
	var removed_instance = _instances.get(entry.index)
	if removed_instance != null:
		Global.yes(_instances.erase(entry.index))
		_destroy_instance(removed_instance)
	
	for i in temp_instances:
		var instance = temp_instances[i]
		if instance != null:
			_change_index(i, instance)
		else:
			var _flag := _instances.erase(i)

func _list_cleared() -> void:
	update_container()
	
	for instance in _instances.values():
		_destroy_instance(instance)
	
	_instances.clear()

func _list_ordered(mapping: Dictionary) -> void:
	var temp_instances := {}
	for i in mapping.values():
		temp_instances[i] = _instances.get(i)
	
	for i in mapping:
		var v: int = mapping[i]
		
		var instance = temp_instances[v]
		if instance != null:
			_change_index(i, instance)
		else:
			var _flag := _instances.erase(i)
	
	if mapping.size() == list.size():
		if Global.profile.animations_enabled:
			yield(get_tree().create_timer(MOVE_TIME / Global.profile.animation_speed), "timeout")
		_ensure_active_visible()

func _change_index(index: int, instance: Control) -> void:
	_instances[index] = instance
	instance.get(PROPERTY_ENTRY).index = index
	_update_position(index, instance)

var active: List.Entry setget _set_active
func _set_active(value) -> void:
	active = value
	
	if not is_inside_tree():
		yield(self, "ready")
	
	_ensure_active_visible()

func _ensure_active_visible() -> void:
	if active != null:
		var instance = _instances.get(active.index)
		if instance == null:
			instance = _create_instance(active)
			if instance is GDScriptFunctionState:
				instance = yield(instance, "completed")
		
		ensure_control_visible(instance)

# --- SCENE INSTANCES ---

var _instance_size: Vector2

func prepare_instance() -> void:
	var parent := get_tree().current_scene
	var instance := item_scene.instance()
	
	parent.add_child(instance)
	_instance_size = instance.get_minimum_size()
	parent.remove_child(instance)
	instance.queue_free()

func update_container() -> void:
	if _instance_size == Vector2():
		yield(get_tree(), "idle_frame")
	
	container.rect_min_size.y = list.size() * _instance_size.y

var _instances := {}

func _instance_process() -> void:
	var visible_rect := Rect2(-container.rect_position, rect_size)
	
	var raw_from := int(floor(visible_rect.position.y / _instance_size.y) - 1.0)
	var raw_to := int(ceil(visible_rect.end.y / _instance_size.y) + 1.0)
	
	var from := int(max(raw_from, 0))
	var to := int(min(raw_to, list.size()))
	
	assert(from >= 0 and to <= list.size())
	
	# Don't remove nodes if scrolling since then touch release event won't propagate.
	if _touch_scrolling_indices.empty():
		for i in _instances:
			if i < from or i >= to:
				var dragging := false
				for job in _dragging_jobs.values():
					if job.index == i:
						dragging = true
						break
				if dragging:
					break
				
				var instance: Control = _instances[i]
				if not instance.get_rect().intersects(visible_rect):
					Global.yes(_instances.erase(i))
					_destroy_instance(instance)
	
	var start_time := OS.get_ticks_usec()
	for i in range(from, to):
		if not i in _instances:
			var entry := list.entry(i)
			var _instance = _create_instance(entry)
			
			var current_time := OS.get_ticks_usec()
			if current_time - start_time > 1000:
				break

func _destroy_instance(instance) -> void:
	container.remove_child(instance)
	instance.queue_free()

func _create_instance(entry: List.Entry) -> Node:
	var instance := item_scene.instance()
	container.add_child(instance)
	
	instance.set(PROPERTY_ENTRY, entry)
	
	_instances[entry.index] = instance
	
	if Global.profile.animations_enabled:
		instance.modulate = Color.transparent
		Global.yes(tween.interpolate_property(instance, "modulate", null, Color.white, FADE_TIME / Global.profile.animation_speed))
		Global.yes(tween.start())
	
	instance.set_anchors_and_margins_preset(PRESET_TOP_WIDE)
	
	_update_position(entry.index, instance)
	
	return instance

var _instance_targets := {}
func _update_position(index: int, instance: Control) -> void:
	var _flag := tween.stop(instance, "rect_position")
	
	var target := index * _instance_size * Vector2.DOWN
	var animate := Global.profile.animations_enabled and instance in _instance_targets
	if animate:
		Global.yes(tween.interpolate_property(instance, "rect_position", null, target, MOVE_TIME / Global.profile.animation_speed))
		Global.yes(tween.start())
	else:
		instance.rect_position = target
	
	_instance_targets[instance] = target
	
	var node_index := 0
	for i in _instances:
		if i < index:
			node_index += 1
	
	container.move_child(instance, node_index)
	#instance.name = "Item%d" % index
	#instance.focus_previous = NodePath("../Item%d" % (index - 1))
	#instance.focus_next = NodePath("../Item%d" % (index + 1))

# --- DRAGGING ---

class DraggingJob:
	var index: int
	var position: Vector2

var _dragging_jobs := {}

func _drag_get_index(container_pos: Vector2) -> int:
	return int(container_pos.y / _instance_size.y)

var _scroll_intermediate := 0.0
func _drag_update(job: DraggingJob, delta: float) -> void:
	if not editable:
		return
	
	_scroll_intermediate -= touch_scroll_curve.interpolate(job.position.y / touch_scroll_margin) * delta
	_scroll_intermediate += touch_scroll_curve.interpolate((rect_size.y - job.position.y) / touch_scroll_margin) * delta
	
	scroll_vertical += int(floor(_scroll_intermediate))
	_scroll_intermediate = fposmod(_scroll_intermediate, 1.0)
	
	var previous_index: int = job.index
	var next_index := _drag_get_index(container.get_transform().xform_inv(job.position))
	
	if next_index < 0 or next_index >= list.size():
		return
	
	if previous_index != next_index:
		var mapping := {}
		mapping[next_index] = previous_index
		
		var step := sign(next_index - previous_index)
		for i in range(previous_index, next_index, step):
			mapping[i] = i + step
		
		list.order(mapping)
		
		# Hack: Hide and show this node to un-press all children buttons.
		var instance = _instances[next_index]
		instance.visible = false
		instance.visible = true
	
	job.index = next_index

func _drag_write(index: int, position: Vector2) -> void:
	var job: DraggingJob = _dragging_jobs.get(index)
	if job == null:
		job = DraggingJob.new()
		_dragging_jobs[index] = job
		
		job.index = _drag_get_index(position)
	
	job.position = container.get_transform().xform(position)
	
	_drag_update(job, 0.0)

var _touch_scrolling_indices := {}

func _on_Container_gui_input(event: InputEvent) -> void:
	if OS.has_touchscreen_ui_hint():
		if event is InputEventScreenTouch:
			if event.pressed:
				var timer := get_tree().create_timer(Global.TOUCH_HOLD_TIME)
				var data := {
					"position": container.get_global_transform().xform(event.position),
					"timer": timer,
					"stopped": false
				}
				_touch_scrolling_indices[event.index] = data
				yield(timer, "timeout")
				if not data.stopped:
					if Input.is_mouse_button_pressed(BUTTON_LEFT):
						if OS.get_name() in ["Android", "iOS"]:
							Input.vibrate_handheld(Global.VIBRATE_TIME)
					var _flag := _touch_scrolling_indices.erase(event.index)
			else:
				var _flag1 := _touch_scrolling_indices.erase(event.index)
				var _flag2 := _dragging_jobs.erase(event.index)
		# TODO: Remove after https://github.com/godotengine/godot/issues/27149
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if not event.pressed:
					yield(get_tree(), "idle_frame")
					_touch_scrolling_indices.clear()
					_dragging_jobs.clear()
		if event is InputEventScreenDrag:
			var data = _touch_scrolling_indices.get(event.index)
			if data != null:
				var pos: Vector2 = container.get_global_transform().xform(event.position)
				if pos.distance_squared_to(data.position) >= Global.CLICK_DRAG_MARGIN_SQ:
					data.stopped = true
				return
			
			_drag_write(event.index, event.position)
	else:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if not event.pressed:
					var _flag := _dragging_jobs.erase(-1)
		if event is InputEventMouseMotion:
			if event.button_mask & BUTTON_LEFT:
				_drag_write(-1, event.position)
