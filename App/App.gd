extends Control
class_name App

func _ready() -> void:
	randomize()
	
	_profile_theme_changed(Global.profile.theme)
	Global.ok(Global.profile.connect("theme_changed", self, "_profile_theme_changed"))
	
	Global.ok(connect("track_finished", self, "next_track"))
	Global.ok(Global.profile.tracks.connect("removed", self, "_profile_track_removed"))
	
	if "--generate-branding" in OS.get_cmdline_args():
		Global.save_profile = false
		Global.profile.animations_enabled = false
		
		for track in Global.profile.tracks.iter():
			queue.add(track)
		
		### SCREENSHOTS ###
		
		if true:
			self.active_view = "import"
			
			var screen = _branding_screen(Vector2(1080, 1920))
			if screen is GDScriptFunctionState:
				screen = yield(screen, "completed")
			
			Global.ok(screen.save_png("res://App/Branding/Screenshots/portrait1.png"))
		
		if true:
			self.active_view = "tracks"
			
			var screen = _branding_screen(Vector2(1080, 1920))
			if screen is GDScriptFunctionState:
				screen = yield(screen, "completed")
			
			Global.ok(screen.save_png("res://App/Branding/Screenshots/portrait2.png"))
		
		if true:
			self.active_view = "settings"
			
			var screen = _branding_screen(Vector2(1080, 1920))
			if screen is GDScriptFunctionState:
				screen = yield(screen, "completed")
			
			Global.ok(screen.save_png("res://App/Branding/Screenshots/portrait3.png"))
		
		if true:
			self.active_view = "tracks"
			
			var screen = _branding_screen(Vector2(1440, 2560))
			if screen is GDScriptFunctionState:
				screen = yield(screen, "completed")
			
			Global.ok(screen.save_png("res://App/Branding/Screenshots/tablet.png"))
		
		### DEVICES ###
		
		var overlay := Image.new()
		Global.ok(overlay.load("res://App/Branding/Screenshots/devices_overlay.png"))
		overlay.lock()
		for x in overlay.get_width():
			for y in overlay.get_height():
				var color := overlay.get_pixel(x, y)
				if color == Color.black:
					overlay.set_pixel(x, y, Color.transparent)
		overlay.unlock()
		
		var canvas := Image.new()
		canvas.create(overlay.get_width(), overlay.get_height(), false, Image.FORMAT_RGBA8)
		
		if true:
			self.active_view = "tracks"
			
			var task = _branding_screen_blit(canvas, Rect2(368, 144, 1408, 792))
			if task is GDScriptFunctionState:
				yield(task, "completed")
		
		if true:
			self.active_view = "tracks"
			
			var task = _branding_screen_blit(canvas, Rect2(144, 376, 360, 720))
			if task is GDScriptFunctionState:
				task = yield(task, "completed")
		
		_branding_blit(canvas, overlay, Vector2())
		
		Global.ok(canvas.save_png("res://App/Branding/Screenshots/devices.png"))
		
		get_tree().quit()
		return

func _branding_screen(size: Vector2) -> Image:
	OS.window_size = size / 4.0
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	get_viewport().size = size
	
	yield(get_tree().create_timer(0.1), "timeout")
	
	self.position = 60.0
	
	if has_node("Layouts/Portrait"):
		$Layouts/Portrait.queue_container.showing = self.active_view == "tracks"
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	var image := get_viewport().get_texture().get_data()
	image.flip_y()
	
	return image

func _branding_screen_blit(canvas: Image, rect: Rect2) -> void:
	var screen = _branding_screen(rect.size * 2.0)
	if screen is GDScriptFunctionState:
		screen = yield(screen, "completed")
	
	screen.shrink_x2()
	_branding_blit(canvas, screen, rect.position)

func _branding_blit(image: Image, put: Image, pos: Vector2) -> void:
	put.convert(Image.FORMAT_RGBA8)
	image.blend_rect(put, Rect2(0.0, 0.0, put.get_width(), put.get_height()), pos)

func _profile_theme_changed(new_theme: Theme) -> void:
	theme = new_theme
	Global.emit_signal("theme_changed")

func _profile_track_removed(entry: TrackList.Entry) -> void:
	var index := queue.find(entry.value)
	if index >= 0:
		queue.remove(index)

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_FOCUS_IN:
			OS.low_processor_usage_mode = false
		NOTIFICATION_WM_FOCUS_OUT:
			OS.low_processor_usage_mode = true

signal track_changed(entry)

var track_history := []

var current: TrackList.Entry setget _set_current
func _set_current(value: TrackList.Entry) -> void:
	if current == value:
		return
	
	current = value
	
	emit_signal("track_changed", current)
	
	if current != null:
		track_history.push_back(current)
		replay()

var current_track: Track setget _set_current_track, _get_current_track
func _set_current_track(_value: Track) -> void:
	assert(false)
func _get_current_track() -> Track:
	return current.value if current != null else null

enum QueueMode {
	REPEAT,
	REPEAT_SINGLE,
	ONCE,
	MAX
}

signal queue_mode_changed(queue_mode)

var queue_mode: int = QueueMode.REPEAT setget _set_queue_mode
func _set_queue_mode(value: int) -> void:
	if queue_mode == value:
		return
	
	queue_mode = value
	
	emit_signal("queue_mode_changed", queue_mode)

func queue_cycle_modes() -> void:
	self.queue_mode = (queue_mode + 1) % QueueMode.MAX

func get_next_track(mode := queue_mode) -> TrackList.Entry:
	if current != null:
		match mode:
			QueueMode.REPEAT:
				return queue.entry((current.index + 1) % queue.size())
			QueueMode.REPEAT_SINGLE:
				return current
			QueueMode.ONCE:
				if current.index < queue.size() - 1:
					return queue.entry((current.index + 1) % queue.size())
	return null

class Queue:
	extends TrackList
	
	var app: App
	func _init(_app):
		app = _app
		
		Global.ok(connect("removed", self, "_queue_on_removed"))
	
	func _queue_on_removed(entry: Entry) -> void:
		if app.current == entry:
			app.current = null
		
		app.track_history.erase(entry)
	
	func add(track: Track, play := false) -> void:
		var entry := ensure_has(track)
		
		if play or app.current == null:
			app.current = entry
	
	func insert(index: int, track: Track, play := false) -> void:
		var entry := ensure_at(index, track)
		
		if play or app.current == null:
			app.current = entry
	
	func shuffle() -> void:
		var size := size()
		var values := range(0, size)
		if app.current != null:
			values.remove(app.current.index)
			values.shuffle()
			values.push_front(app.current.index)
		else:
			values.shuffle()
		
		var mapping := {}
		
		for i in size:
			mapping[i] = values[i]
		
		order(mapping)
	
	func play_next(track: Track) -> void:
		Global.profile.tracks.ensure_has(track)
		
		var index := size()
		if app.current != null:
			index = app.current.index + 1
		
		insert(index, track)

var queue := Queue.new(self)

signal state_changed(playing)

var playing := true setget _set_playing
func _set_playing(value: bool) -> void:
	if playing == value:
		return
	
	playing = value
	
	emit_signal("state_changed", playing)

func toggle_playing() -> void:
	if playing:
		pause()
	else:
		play()

func play() -> void:
	self.playing = true

func pause() -> void:
	self.playing = false

func stop() -> void:
	self.playing = false
	self.position = 0.0

func replay() -> void:
	self.playing = true
	self.position = 0.0

signal seeking_changed(seeking)

var seeking := false setget _set_seeking
func _set_seeking(value: bool) -> void:
	if seeking == value:
		return
	
	seeking = value
	
	emit_signal("seeking_changed", seeking)

signal track_finished
signal position_changed(position)

# Changing this will not call the position changed signal.
# This is useful for automatic position change over time.
var real_position: float setget _set_real_position
func _set_real_position(value: float) -> void:
	real_position = value
	
	var duration = 0.0
	if current != null:
		duration = get_duration()
		if duration is GDScriptFunctionState:
			duration = yield(duration, "completed")
	
	real_position = clamp(real_position, 0.0, duration)

# Changing this will call the position changed signal.
# This should only be changed when the user makes a manual action.
var position: float setget _set_player_position, _get_player_position
func _set_player_position(value: float) -> void:
	var task = _set_real_position(value)
	if task is GDScriptFunctionState:
		yield(task, "completed")
	
	position = real_position
	emit_signal("position_changed", position)
func _get_player_position() -> float:
	return real_position

func get_duration() -> float:
	if current != null:
		return current.value.duration
	
	return 0.0

func next_track(manual := false) -> void:
	var next := get_next_track()
	
	if current == next:
		if manual:
			# Manual next track: Switch instead of looping the same track.
			next = get_next_track(QueueMode.REPEAT)
		else:
			replay()
	
	self.current = next

func previous_track() -> void:
	if track_history.size() > 1:
		var _remove_current: TrackList.Entry = track_history.pop_back()
		self.current = track_history.pop_back()

signal volume_changed(volume)

var volume := 0.5 setget _set_volume
func _set_volume(value: float) -> void:
	volume = value
	
	emit_signal("volume_changed", volume)

signal speed_changed(volume)

var speed := 1.0 setget _set_speed
func _set_speed(value: float) -> void:
	speed = value
	
	emit_signal("speed_changed", speed)

signal buffering_changed(buffering)

var buffering := false setget _set_buffering
func _set_buffering(value: bool) -> void:
	if buffering == value:
		return
	
	buffering = value
	
	emit_signal("buffering_changed", buffering)

signal active_view_changed(screen)

var active_view = "home" setget _set_active_view
func _set_active_view(value) -> void:
	if typeof(active_view) == typeof(value):
		if active_view == value:
			return
	
	active_view = value
	
	emit_signal("active_view_changed", active_view)
