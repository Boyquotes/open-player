extends CanvasLayer

onready var window: WindowDialog = $WindowDialog
onready var author: LineEdit = $WindowDialog/MarginContainer/VBoxContainer/Author
onready var title: LineEdit = $WindowDialog/MarginContainer/VBoxContainer/Title
onready var image: LineEdit = $WindowDialog/MarginContainer/VBoxContainer/Image

var track: Track

func _ready() -> void:
	window.popup_centered_minsize()
	
	window.window_title = tr("TRACK_EDITOR_WINDOW").format([track.get_text()])
	author.text = track.author
	title.text = track.title
	image.text = track.custom_image

func _on_Save_pressed() -> void:
	track.author = author.text
	track.title = title.text
	track.custom_image = image.text
	window.hide()

func _on_WindowDialog_popup_hide() -> void:
	queue_free()
