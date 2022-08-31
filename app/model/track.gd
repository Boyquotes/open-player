extends Resource
class_name Track

signal list_inserted(list, entry)
signal list_removed(list, entry)

export var source: Resource setget _set_source
func _set_source(value: TrackSource) -> void:
	source = value
	emit_changed()

export var author: String setget _set_author
func _set_author(value: String) -> void:
	author = value
	emit_changed()

export var title: String setget _set_title
func _set_title(value: String) -> void:
	title = value
	emit_changed()

export var duration: float setget _set_duration
func _set_duration(value: float) -> void:
	duration = value
	emit_changed()

export var custom_image: String setget _set_custom_image
func _set_custom_image(value: String) -> void:
	custom_image = value
	emit_changed()

func get_text() -> String:
	return "%s - %s" % [author, title]

func _init(_source: TrackSource = null, _author := "", _title := "", _duration := 0.0, _custom_image := ""):
	source = _source
	author = _author
	title = _title
	duration = _duration
	custom_image = _custom_image

func key() -> Array:
	return [source.get_type(), source.get_id()]

func get_texture(preview := false) -> Texture:
	var url := custom_image
	
	if url.empty():
		if source is TrackSourceYouTube:
			if preview:
				url = source.preview_url
			else:
				url = source.image_url
	
	if url.empty():
		return null
	
	var path := "user://image_cache/%s.%s" % [url.hash(), url.get_extension()]
	var dir := Directory.new()
	Global.ok(dir.make_dir_recursive(path.get_base_dir()))
	
	if not dir.file_exists(path):
		var http := HTTPRequest.new()
		Global.add_child(http)
		http.download_file = path
		Global.ok(http.request(url))
		yield(http, "request_completed")
	
	var image := Image.new()
	Global.ok(image.load(path))
	
	var texture := ImageTexture.new()
	texture.create_from_image(image)
	return texture

### CONSTRUCTION ###

static func create_file(original_path: String) -> Track:
	var path: String = Global.get_absolute_path(original_path)
	
	print("Create track from path: ", path)
	
	var _source: TrackSource
	if path.ends_with(".mp3"):
		_source = TrackSourceMP3.new(path)
	elif path.ends_with(".wav"):
		_source = TrackSourceWAV.new(path)
	elif path.ends_with(".ogg"):
		_source = TrackSourceOGG.new(path)
	else:
		return null
	
	var group := "AUTHOR"
	var object := "TITLE"
	var segments := path.split("/")
	if segments.size() >= 2:
		group = segments[segments.size() - 2]
		object = segments[segments.size() - 1]
		object = object.left(object.find_last("."))
	
	var stream := _source.create_stream()
	var _duration := stream.get_length()
	
	return create_named(_source, group, object, _duration)

static func create_youtube(data: VideoData) -> Track:
	var _source := TrackSourceYouTube.new(data.id)
	return create_named(_source, data.channel, data.title, data.duration)

static func create_named(_source: TrackSource, group: String, object: String, _duration: float) -> Track:
	# TODO: Cyclic references
	var _Track = load("res://app/model/track.gd")
	
	var parsed_author := group
	var parsed_title := object
	var sections := object.split(" - ", false)
	if sections.size() >= 2:
		parsed_author = MetaCleaner.strip_channel(sections[0])
		parsed_title = MetaCleaner.strip_title(sections[1])
	
	return _Track.new(_source, parsed_author, parsed_title, _duration, "")
