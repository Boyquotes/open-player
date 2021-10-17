extends Node

var godotcord
var godotcord_activity_manager

onready var cooldown: Timer = $Cooldown

func _ready() -> void:
	if not Engine.has_singleton("Godotcord"):
		printraw("Godotcord not found.\n")
		queue_free()
		return
	
	godotcord = Engine.get_singleton("Godotcord")
	godotcord_activity_manager = Engine.get_singleton("GodotcordActivityManager")
	
	Global.ok(Global.profile.connect("changed", self, "_on_profile_changed"))
	Global.ok(Global.player.connect("state_changed", self, "_on_state_changed"))
	Global.ok(Global.player.connect("track_changed", self, "_on_track_changed"))
	Global.ok(Global.player.connect("position_changed", self, "_on_position_changed"))
	
	_update_activity()
	printraw("Godotcord is ready!\n")

func _process(_delta: float) -> void:
	if _initialized:
		godotcord.run_callbacks()

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
			godotcord_activity_manager.clear_activity()
		return
	
	if not _initialized:
		var err: int = godotcord.init(867716605148397569, godotcord.CreateFlags_NO_REQUIRE_DISCORD)
		if err != OK:
			printraw("Godotcord initialization failed: %d.\n" % err)
			queue_free()
			return
		
		_initialized = true
	
	if not cooldown.is_stopped():
		_queue_update = true
		return
	cooldown.start()
	
	var activity = ClassDB.instance("GodotcordActivity")
	activity.large_image = "logo"
	activity.small_image = "get"
	activity.small_text = "Download OpenPlayer at https://op.nathan.sh/"
	
	var track := Global.player.current_track
	if track != null:
		if Global.player.playing:
			activity.details = "%s - %s" % [track.author, track.title]
			activity.start = OS.get_unix_time() - int(round(Global.player.position))
		else:
			activity.details = "Paused"
	else:
		activity.details = "Idle"
	
	godotcord_activity_manager.set_activity(activity)

var _queue_update := false
func _on_Timer_timeout() -> void:
	if _queue_update:
		_update_activity()
		_queue_update = false
