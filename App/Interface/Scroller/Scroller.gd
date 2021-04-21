extends ScrollContainer

export var text: String setget _set_text
func _set_text(value: String) -> void:
	text = value
	
	if not is_inside_tree():
		yield(self, "ready")
	
	update_size()

export var active := false setget _set_active
func _set_active(value: bool) -> void:
	active = value
	
	if not is_inside_tree():
		yield(self, "ready")
	
	update_size()

export var loop_delimiter := "    "

onready var label: Label = $Label

var text_size: float
var delim_size: float
var loop_size: float

var scroll := 0.0 setget _set_scroll
func _set_scroll(value: float) -> void:
	scroll = value
	
	scroll_horizontal = int(scroll)

var _queue_update_size := true
func _process(delta: float) -> void:
	if _queue_update_size:
		text_size = label.get_font("font").get_string_size(text).x
		delim_size = label.get_font("font").get_string_size(loop_delimiter).x
		if active and text_size > rect_size.x:
			label.text = text + loop_delimiter + text
			loop_size = text_size + delim_size
		else:
			label.text = text
			loop_size = 0.0
		_queue_update_size = false
	
	if active and text_size > rect_size.x:
		self.scroll = fposmod(scroll + delta * 40.0, loop_size)
	else:
		self.scroll = 0.0

func update_size() -> void:
	_queue_update_size = true
