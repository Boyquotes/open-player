extends Resource
class_name Track

signal list_inserted(list, entry)
signal list_removed(list, entry)

export(Resource) var source
export var author: String
export var title: String
export var duration: float

func _init(_source: TrackSource = null, _author := "", _title := "", _duration := 0.0):
	source = _source
	author = _author
	title = _title
	duration = _duration

func key() -> Array:
	return [source.get_type(), source.get_id()]

static func create_file(original_path: String) -> Track:
	print("Create file: ", original_path)
	
	var file := File.new()
	var id := file.get_sha256(original_path)
	
	var _source: TrackSource
	if original_path.ends_with(".mp3"):
		_source = TrackSourceMP3.new(id)
	elif original_path.ends_with(".wav"):
		_source = TrackSourceWAV.new(id)
	elif original_path.ends_with(".ogg"):
		_source = TrackSourceOGG.new(id)
	else:
		return null
	
	var dir := Directory.new()
	Global.ok(dir.make_dir_recursive("user://audio"))
	Global.ok(dir.copy(original_path, _source.get_path()))
	
	var group := "AUTHOR"
	var object := "TITLE"
	var segments := original_path.split("/")
	if segments.size() >= 2:
		group = segments[segments.size() - 2]
		object = segments[segments.size() - 1]
		object = object.substr(0, object.find_last("."))
	
	var stream := _source.create_stream()
	var _duration := stream.get_length()
	
	return create_named(_source, group, object, _duration)

static func create_youtube(data: VideoData) -> Track:
	var _source := TrackSourceYouTube.new(data.id)
	return create_named(_source, data.channel, data.title, data.duration)

static func create_named(_source: TrackSource, group: String, object: String, _duration: float) -> Track:
	# TODO: Cyclic references
	var _Track = load("res://App/Model/Track.gd")
	
	var parsed_author := group
	var parsed_title := object
	var sections := object.split(" - ", false)
	if sections.size() >= 2:
		parsed_author = MetaCleaner.strip_channel(sections[0])
		parsed_title = MetaCleaner.strip_title(sections[1])
	
	return _Track.new(_source, parsed_author, parsed_title, _duration)
