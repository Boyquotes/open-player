extends TrackSource
class_name TrackSourceOGG

export var path: String

func _init(_path := ""):
	path = _path

func create_stream() -> AudioStream:
	var stream := AudioStreamOGGVorbis.new()
	
	var file := File.new()
	Global.ok(file.open(path, File.READ))
	stream.data = file.get_buffer(file.get_len())
	
	return stream

func get_type() -> String:
	return "ogg"

func get_id() -> String:
	return path
