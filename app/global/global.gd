extends Node

const TOUCH_HOLD_TIME := 0.3
const VIBRATE_TIME := 20
const CLICK_DRAG_MARGIN_SQ := 15.0 * 15.0

signal go_back(request)

var profile: Profile
onready var player: App = get_tree().current_scene
onready var autosave_timer := Timer.new()

func _enter_tree() -> void:
	profile = _load_profile()

func _ready() -> void:
	### AUTOSAVE ###
	autosave_timer.wait_time = 600.0
	autosave_timer.autostart = true
	autosave_timer.name = "Autosave"
	ok(autosave_timer.connect("timeout", self, "_save_profile"))
	add_child(autosave_timer)

func _exit_tree() -> void:
	if not autosave_timer.is_stopped():
		_save_profile()

### PROFILES ###

const _PROFILE_VERSION := 0

func _get_profile_path(v: int) -> String:
	return "user://profile.%d.tres" % v

func _load_profile() -> Profile:
	debug("Loading profile...")
	
	# Migrate old save location, if it exists.
	var legacy_path := OS.get_user_data_dir().get_base_dir().plus_file("godot").plus_file("app_userdata").plus_file("OpenPlayer")
	var target_path := OS.get_user_data_dir()
	var dir := Directory.new()
	if dir.open(legacy_path) == OK:
		ok(dir.list_dir_begin(true))
		while true:
			var path := dir.get_next()
			if path.empty():
				break
			var _rename_err := dir.rename(legacy_path.plus_file(path), target_path.plus_file(path))
		dir.list_dir_end()
		ok(OS.move_to_trash(legacy_path))
		
		print("Migrated data from '", legacy_path, "' to '", target_path, "'")
	
	var path := _get_profile_path(_PROFILE_VERSION)
	if ResourceLoader.exists(path):
		return load(path) as Profile
	return Profile.new()

func _save_profile() -> void:
	debug("Saving profile...")
	
	var path := _get_profile_path(_PROFILE_VERSION)
	ok(ResourceSaver.save(path + ".part.tres", profile))
	
	var dir := Directory.new()
	ok(dir.rename(path + ".part.tres", path))

### GO BACK ###

class GoBackRequest:
	var exit := true

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		var request := GoBackRequest.new()
		emit_signal("go_back", request)
		if request.exit:
			_save_profile()
			get_tree().quit()

### UTILITIES ###

func get_absolute_path(local: String) -> String:
	return ProjectSettings.globalize_path(local)

func display_time(time: float, show_deciseconds := false) -> String:
	var hours := int(time / 3600.0)
	time = fmod(time, 3600.0)
	var minutes := int(time / 60.0)
	time = fmod(time, 60.0)
	var seconds := int(time)
	time = fmod(time, 1.0)
	var deciseconds := int(time * 10.0)
	
	var string := ""
	if hours:
		string += "%02d" % hours if string else str(hours)
	string += ":%02d" % minutes if string else str(minutes)
	string += ":%02d" % seconds if string else str(seconds)
	if show_deciseconds:
		string += ".%01d" % deciseconds
	
	return string

func ok(err: int) -> void:
	assert(err == OK)

func yes(flag: bool) -> void:
	assert(flag)

func debug(message: String) -> void:
	# Don't run this code in release builds.
	assert(print(message) or true)
