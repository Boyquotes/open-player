tool
extends Button

onready var _is_ready := true
onready var texture_rect: TextureRect = $Texture
onready var hint_node = $Hint

export var texture: Texture setget _set_texture
func _set_texture(value: Texture) -> void:
	texture = value
	
	if not _is_ready:
		return
	
	_update_style()

export(float, 0.0, 1.0, 0.05) var icon_size := 0.5 setget _set_icon_size
func _set_icon_size(value: float) -> void:
	icon_size = value
	
	if not _is_ready:
		return
	
	_update_style()

export var flip: bool setget _set_flip
func _set_flip(value: bool) -> void:
	flip = value
	
	if not _is_ready:
		yield(self, "ready")
	
	texture_rect.flip_h = flip

export var hint: String setget _set_hint
func _set_hint(value: String) -> void:
	hint = value
	
	if not _is_ready:
		yield(self, "ready")
	
	hint_node.text = hint

func _update_style() -> void:
	texture_rect.texture = texture
	texture_rect.rect_min_size = rect_size * icon_size
	texture_rect.set_anchors_and_margins_preset(Control.PRESET_CENTER)
	
	modulate = get_color("icon")

func _ready() -> void:
	_update_style()
	Global.ok(Global.connect("theme_changed", self, "_update_style"))

func _process(_delta: float) -> void:
	rect_min_size.x = rect_size.y
