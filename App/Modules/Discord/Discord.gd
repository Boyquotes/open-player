extends Node

class Driver:
	func create(id: String) -> int:
		return OK
	
	func destroy() -> void:
		pass
	
	func clear() -> void:
		pass
	
	func run_callbacks() -> void:
		pass
	
	func update_activity(text: String, timestamp := 0) -> void:
		pass

class GodotcordDriver:
	extends Driver
	
	var godotcord
	var godotcord_activity_manager
	
	func _init():
		godotcord = Engine.get_singleton("Godotcord")
		godotcord_activity_manager = Engine.get_singleton("GodotcordActivityManager")
	
	func create(id: String) -> int:
		return godotcord.init(int(id), godotcord.CreateFlags_NO_REQUIRE_DISCORD)
	
	func clear() -> void:
		godotcord_activity_manager.clear_activity()
	
	func run_callbacks() -> void:
		godotcord.run_callbacks()
	
	func update_activity(text: String, timestamp := 0) -> void:
		var activity = ClassDB.instance("GodotcordActivity")
		
		activity.large_image = "logo"
		activity.small_image = "get"
		activity.small_text = "Download OpenPlayer at https://op.nathan.sh/"
		activity.details = text
		activity.start = timestamp
		
		godotcord_activity_manager.set_activity(activity)

var driver: Driver

onready var update_cooldown: Timer = $Cooldown

func _ready() -> void:
	if Engine.has_singleton("Godotcord"):
		driver = GodotcordDriver.new()
	else:
		queue_free()
		return
	
	Global.ok(Global.profile.connect("changed", self, "_on_profile_changed"))
	Global.ok(Global.player.connect("state_changed", self, "_on_state_changed"))
	Global.ok(Global.player.connect("track_changed", self, "_on_track_changed"))
	Global.ok(Global.player.connect("position_changed", self, "_on_position_changed"))
	
	_update_activity()

func _exit_tree() -> void:
	if _initialized:
		driver.destroy()

func _process(_delta: float) -> void:
	if _initialized:
		driver.run_callbacks()

func _on_state_changed(_playing: bool) -> void:
	_update_activity()

func _on_track_changed(_entry: TrackList.Entry) -> void:
	_update_activity()

func _on_position_changed(_position: float) -> void:
	_update_activity()

func _on_profile_changed() -> void:
	_update_activity()

var _initialized := false
func _update_activity() -> void:
	if not Global.profile.discord_rich_presence:
		if _initialized:
			driver.clear()
		return
	
	if not _initialized:
		var err := driver.create("867716605148397569")
		if err != OK:
			queue_free()
			return
		
		_initialized = true
	
	if not update_cooldown.is_stopped():
		_queue_update = true
		return
	update_cooldown.start()
	
	var track := Global.player.current_track
	if track != null:
		if Global.player.playing:
			driver.update_activity(
				"%s - %s" % [track.author, track.title],
				OS.get_unix_time() - int(Global.player.position)
			)
		else:
			driver.update_activity("Paused")
	else:
		driver.update_activity("Idle")

var _queue_update := false
func _on_Timer_timeout() -> void:
	if _queue_update:
		_update_activity()
		_queue_update = false
