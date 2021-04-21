extends TrackSource
class_name TrackSourceYouTube

export var id: String

func _init(_id := ""):
	id = _id

func create_stream() -> AudioStream:
	var stream := AudioStreamYT.new()
	stream.create(id)
	return stream

func delete() -> void:
	var dir := Directory.new()
	var _err1 := dir.remove("user://youtube_cache/%s.webm.part" % id)
	var _err2 := dir.remove("user://youtube_cache/%s.webm" % id)

func get_type() -> String:
	return "yt"

func get_id() -> String:
	return id
