extends Node

# ---
# Godotcord is disabled temporarily since the Game SDK does not support custom buttons.
# ---

const CLIENT_ID := 867716605148397569
const LARGE_IMAGE := "logo"
const LARGE_TEXT := "OpenPlayer - Music Player by nathanfranke"
#const SMALL_IMAGE := "get"
#const SMALL_TEXT := "Download OpenPlayer at https://op.nathan.sh/"

class Driver:
	func create() -> int:
		return OK
	
	func destroy() -> void:
		pass
	
	func clear() -> void:
		pass
	
	func run_callbacks() -> void:
		pass
	
	func update_activity() -> void:
		pass

class PypresenceDriver:
	extends Driver
	
	var path := Global.get_absolute_path("user://discord_rpc_pypresence.py")
	var data_path := Global.get_absolute_path("user://discord_rpc_pypresence.json")
	var process := -1
	
	func create() -> int:
		var text := """#!/usr/bin/env python3
import json
import os
import pypresence
import sys
import time

pid = int(sys.argv[1])
rpc = pypresence.Presence(client_id="%d")
rpc.connect()

path = sys.argv[2]
last_modified = 0
while True:
\ttry:
\t\tos.kill(pid, 0)
\texcept OSError:
\t\tbreak
\t
\tmodified = os.stat(path).st_mtime
\tif modified > last_modified:
\t\tfile = open(path)
\t\tdata = json.load(file)
\t\tfile.close()
\t\t
\t\trpc.update(pid=pid, **data)
\t\tlast_modified = modified
\t
\ttime.sleep(1.0)
""" % CLIENT_ID
		
		var file := File.new()
		if file.get_sha256(path) != text.sha256_text():
			Global.ok(file.open(path, File.WRITE))
			file.store_string(text)
			file.close()
		
		return OK
	
	func kill() -> void:
		if process >= 0:
			Global.ok(OS.kill(process))
			process = 0
	
	func destroy() -> void:
		kill()
	
	func clear() -> void:
		var file := File.new()
		Global.ok(file.open(data_path, File.WRITE))
		file.store_string(JSON.print({}))
		file.close()
	
	func update_activity() -> void:
		var data := {
			"large_image": LARGE_IMAGE,
			"large_text": LARGE_TEXT,
			"buttons": [
				{
					"label": "Download OpenPlayer",
					"url": "https://op.nathan.sh/"
				}
			]
		}
		
		var track := Global.player.current_track
		if track != null:
			data.details = track.get_text()
			if Global.player.playing:
				data.start = OS.get_unix_time() - int(Global.player.position)
			else:
				data.state = "Paused"
			
			if track.source is TrackSourceYouTube:
				data.buttons.push_back({
					"label": "Listen on YouTube",
					"url": "https://www.youtube.com/watch?v=%s" % track.source.id
				})
		else:
			data.details = "Idle"
		
		var file := File.new()
		Global.ok(file.open(data_path, File.WRITE))
		file.store_string(JSON.print(data))
		file.close()
		
		if process == -1:
			process = OS.execute("python", [path, OS.get_process_id(), data_path], false)
	
	static func detect() -> bool:
		# Test if python is installed, along with the pypresence module.
		var status := OS.execute("python", ["-c", "import pypresence"])
		return status == 0

#class GodotcordDriver:
#	extends Driver
#
#	var godotcord
#	var godotcord_activity_manager
#
#	func create() -> int:
#		godotcord = Engine.get_singleton("Godotcord")
#		godotcord_activity_manager = Engine.get_singleton("GodotcordActivityManager")
#		return godotcord.init(CLIENT_ID, godotcord.CreateFlags_NO_REQUIRE_DISCORD)
#
#	func clear() -> void:
#		godotcord_activity_manager.clear_activity()
#
#	func run_callbacks() -> void:
#		godotcord.run_callbacks()
#
#	func update_activity() -> void:
#		var activity = ClassDB.instance("GodotcordActivity")
#
#		activity.large_image = LARGE_IMAGE
#		activity.large_text = LARGE_TEXT
#		activity.small_image = SMALL_IMAGE
#		activity.small_text = SMALL_TEXT
#
#		var track := Global.player.current_track
#		if track != null:
#			activity.details = track.get_text()
#			if Global.player.playing:
#				activity.start = OS.get_unix_time() - int(Global.player.position)
#			else:
#				activity.state = "Paused"
#		else:
#			activity.state = "Idle"
#
#		godotcord_activity_manager.set_activity(activity)
#
#	static func detect() -> bool:
#		return Engine.has_singleton("Godotcord")

var driver: Driver

onready var update_cooldown: Timer = $Cooldown

func _enter_tree() -> void:
	if PypresenceDriver.detect():
		driver = PypresenceDriver.new()
#	elif GodotcordDriver.detect():
#		driver = GodotcordDriver.new()
	else:
		queue_free()
		return
	
	Global.set_meta("discord_rich_presence_available", true)

func _ready() -> void:
	if driver != null:
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
		var err := driver.create()
		if err != OK:
			queue_free()
			return
		
		_initialized = true
	
	if not update_cooldown.is_stopped():
		_queue_update = true
		return
	update_cooldown.start()
	
	driver.update_activity()

var _queue_update := false
func _on_Timer_timeout() -> void:
	if _queue_update:
		_update_activity()
		_queue_update = false
