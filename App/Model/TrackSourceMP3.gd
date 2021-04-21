extends TrackSource
class_name TrackSourceMP3

export var id: String

func _init(_id := ""):
	id = _id

func get_path() -> String:
	return "user://audio/%s.mp3" % id

func create_stream() -> AudioStream:
	var stream := AudioStreamMP3.new()
	
	var file := File.new()
	Global.ok(file.open(get_path(), File.READ))
	stream.data = file.get_buffer(file.get_len())
	
	return stream

func delete() -> void:
	var dir := Directory.new()
	var _err := dir.remove(get_path())

func get_type() -> String:
	return "mp3"

func get_id() -> String:
	return id
