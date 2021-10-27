extends TrackSource
class_name TrackSourceMP3

export var path: String

func _init(_path := ""):
	path = _path

func create_stream() -> AudioStream:
	var stream := AudioStreamMP3.new()
	
	var file := File.new()
	Global.ok(file.open(path, File.READ))
	stream.data = file.get_buffer(file.get_len())
	
	return stream

func get_type() -> String:
	return "mp3"

func get_id() -> String:
	return path
