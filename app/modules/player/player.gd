extends Node

onready var handle: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	_update_track(Global.player.current, Global.player.position)
	Global.ok(Global.player.connect("track_changed", self, "_update_track"))
	Global.ok(Global.player.connect("position_changed", self, "_update_position"))
	
	_update_speed(Global.player.speed)
	Global.ok(Global.player.connect("speed_changed", self, "_update_speed"))
	
	_update_state_seeking()
	Global.ok(Global.player.connect("state_changed", self, "_update_state_seeking"))
	Global.ok(Global.player.connect("seeking_changed", self, "_update_state_seeking"))
	
	_update_volume(Global.profile.volume)
	Global.ok(Global.profile.connect("volume_changed", self, "_update_volume"))

func _process(_delta: float) -> void:
	var buffering := false
	
	if handle.stream != null:
		Global.player.real_position = handle.get_playback_position()
		if Global.player.playing and handle.get_stream_playback().has_method("is_buffering"):
			buffering = handle.get_stream_playback().is_buffering()
	
	Global.player.buffering = buffering

func _update_track(entry: TrackList.Entry, position := 0.0) -> void:
	handle.stream = null
	Global.player.real_position = position
	
	if entry != null:
		var stream: AudioStream = entry.value.source.create_stream()
		handle.stream = stream
		handle.play(position)

func _update_state_seeking(_flag = null) -> void:
	if Global.player.current != null:
		var playing := Global.player.playing
		
		if Global.player.seeking and not Input.is_action_pressed("seek_preview"):
			playing = false
		
		handle.stream_paused = not playing

func _update_position(position: float) -> void:
	if Global.player.current != null:
		handle.seek(position)

func _update_speed(speed: float) -> void:
	handle.pitch_scale = speed

func _update_volume(volume: float) -> void:
	handle.volume_db = linear2db(volume * 1.5)

func _on_AudioStreamPlayer_finished() -> void:
	if handle.stream != null:
		handle.play()
		Global.player.next_track()
