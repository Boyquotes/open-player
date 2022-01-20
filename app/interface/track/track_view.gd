tool
extends DummyContainer

signal selected
signal removed

onready var button: Button = $Button
onready var info := $MarginContainer/HBoxContainer/Info
onready var loading := info.get_node("Main/Loading")
onready var title := info.get_node("Main/Title")
onready var meta := info.get_node("Meta")
onready var add_to_queue: Button = $MarginContainer/HBoxContainer/AddToQueue
onready var remove: Button = $MarginContainer/HBoxContainer/Remove
onready var long_press: Timer = $LongPress

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
	if entry != null:
		entry.value.disconnect("changed", self, "_update_track")
	
	entry = value
	
	if entry != null:
		Global.ok(entry.value.connect("changed", self, "_update_track"))
	
	_update_track()

func _is_active() -> bool:
	return show_active and Global.player.current != null and Global.player.current == entry

func _update_track() -> void:
	if entry != null:
		title.text = entry.value.title
		meta.text = "%s \u2022 %s" % [entry.value.author, Global.display_time(entry.value.duration)]
		button.text = entry.value.get_text()
	else:
		title.text = ""
		meta.text = ""
		button.text = ""
	
	update_active()
	
	title.update_size()
	meta.update_size()

func _update_style() -> void:
	var style := button.get_stylebox("track_active") if _is_active() else button.get_stylebox("track_normal")
	button.add_stylebox_override("normal", style)
	button.add_stylebox_override("pressed", style)
	button.add_stylebox_override("hover", style)
	
	title.label.add_font_override("font", title.label.get_font("track_title"))
	meta.label.add_font_override("font", meta.label.get_font("track_meta"))

var _previous_active := false
func update_active() -> void:
	var active := _is_active()
	if _previous_active != active:
		_previous_active = active
		
		title.active = active
		meta.active = active
		_update_style()
		
		while _is_active():
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

func _open_context() -> void:
	var instance := preload("res://app/interface/track/menu/track_menu.tscn").instance()
	instance.entry = entry
	get_tree().current_scene.add_child(instance)

func _on_AddToQueue_pressed() -> void:
	add()

func _on_Remove_pressed() -> void:
	emit_signal("removed")

func _on_Button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			BUTTON_RIGHT:
				if event.pressed:
					_open_context()
			BUTTON_MIDDLE:
				if event.pressed:
					Global.player.queue.play_next(entry.value)

func _on_Button_button_down() -> void:
	if OS.has_touchscreen_ui_hint():
		long_press.start()

func _on_Button_pressed() -> void:
	button.pressed = false
	
	# HACK: If we are re-ordering the list view, ignore the button press.
	if not is_visible_in_tree():
		return
	
	if OS.has_touchscreen_ui_hint():
		if long_press.is_stopped():
			_open_context()
		else:
			emit_signal("selected")
	else:
		emit_signal("selected")

func _on_LongPress_timeout() -> void:
	if OS.get_name() in ["Android", "iOS"] && Global.profile.vibrate_on_touch:
		Input.vibrate_handheld(Global.VIBRATE_TIME)
