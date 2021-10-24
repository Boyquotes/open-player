extends PanelContainer

signal selected
signal removed

onready var info := $HBoxContainer/Info
onready var loading := info.get_node("Main/Loading")
onready var title := info.get_node("Main/Title")
onready var meta := info.get_node("Meta")
onready var add_to_queue := $HBoxContainer/AddToQueue
onready var remove := $HBoxContainer/Remove

export var playable := true setget _set_playable
func _set_playable(value: bool) -> void:
	playable = value
	
	if not is_inside_tree():
		yield(self, "ready")
	
	add_to_queue.visible = playable

export var removable := true setget _set_removable
func _set_removable(value: bool) -> void:
	removable = value
	
	if not is_inside_tree():
		yield(self, "ready")
	
	remove.visible = removable

export var show_active := false

var entry: TrackList.Entry setget _set_entry
func _set_entry(value: TrackList.Entry) -> void:
	entry = value
	
	update_track()

func is_active() -> bool:
	return show_active and Global.player.current != null and Global.player.current == entry

func update_track() -> void:
	title.text = "Invalid"
	meta.text = ""
	
	update_active()
	
	if entry != null:
		title.text = entry.value.title
		meta.text = "%s \u2022 %s" % [entry.value.author, Global.display_time(entry.value.duration)]
		
		title.update_size()
		meta.update_size()

func _update_style() -> void:
	add_stylebox_override("panel", get_stylebox("track_active") if is_active() else get_stylebox("track_normal"))
	
	title.label.add_font_override("font", title.label.get_font("track_title"))
	meta.label.add_font_override("font", meta.label.get_font("track_meta"))

var _previous_active := false
func update_active() -> void:
	var active := is_active()
	if _previous_active != active:
		_previous_active = active
		
		title.active = active
		meta.active = active
		_update_style()
		
		while is_active():
			loading.active = Global.player.buffering
			yield(Global.player, "buffering_changed")
		loading.active = false

func _ready() -> void:
	_update_style()
	Global.ok(Global.profile.connect("theme_changed", self, "_update_style"))
	
	Global.ok(connect("selected", self, "_on_selected"))
	
	update_active()

func _exit_tree() -> void:
	Global.profile.disconnect("theme_changed", self, "_update_style")
	disconnect("selected", self, "_on_selected")

func _on_selected() -> void:
	if playable:
		play()

func play() -> void:
	_add(true)

func add() -> void:
	_add(false)

func _add(play: bool) -> void:
	Global.profile.tracks.ensure_has(entry.value)
	Global.player.queue.add(entry.value, play)

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

func _on_TrackView_gui_input(event: InputEvent) -> void:
	if OS.has_touchscreen_ui_hint():
		if event is InputEventScreenTouch:
			if event.pressed:
				_select_start(event.index, event.position)
				
				var timer := get_tree().create_timer(Global.TOUCH_HOLD_TIME)
				_touch_timers[event.index] = timer
				yield(timer, "timeout")
				if _selecting_jobs.has(event.index):
					if OS.get_name() in ["Android", "iOS"]:
						Input.vibrate_handheld(Global.VIBRATE_TIME)
					Global.yes(_touch_timers.erase(event.index))
			else:
				if not _touch_timers.erase(event.index):
					if _selecting_jobs.erase(event.index):
						_open_context()
				_select_end(event.index)
		# TODO: Remove after https://github.com/godotengine/godot/issues/27149
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT:
				if not event.pressed:
					yield(get_tree(), "idle_frame")
					_selecting_jobs.clear()
		if event is InputEventScreenDrag:
			_select_update(event.index, event.position)
	else:
		if event is InputEventMouseButton:
			match event.button_index:
				BUTTON_LEFT:
					if event.pressed:
						_select_start(-1, event.position)
					else:
						_select_end(-1)
				BUTTON_RIGHT:
					if event.pressed:
						_open_context()
				BUTTON_MIDDLE:
					if event.pressed:
						Global.player.queue.play_next(entry.value)
		if event is InputEventMouseMotion:
			if event.button_mask & BUTTON_LEFT:
				_select_update(-1, event.position)

func _open_context() -> void:
	var menu := preload("res://App/Interface/Track/Menu/TrackMenu.tscn").instance()
	menu.entry = entry
	add_child(menu)

func _on_Remove_pressed() -> void:
	emit_signal("removed")
