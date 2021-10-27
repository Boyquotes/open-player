extends Control

onready var _is_ready := true
onready var icon: TextureRect = $Icon
onready var tween: Tween = $Tween

export var rotation_speed := 360.0

export var active := true setget _set_active
func _set_active(value: bool) -> void:
	active = value
	
	if not _is_ready:
		yield(self, "ready")
	
	_animate()

func _ready() -> void:
	_animate(true)

func _process(delta: float) -> void:
	icon.rect_pivot_offset = icon.rect_size / 2.0
	icon.rect_rotation = fposmod(icon.rect_rotation + rotation_speed * delta, 360.0)

func _animate(instant := false) -> void:
	var target_size := Vector2(rect_size.y if active else 0.0, rect_min_size.y)
	var target_color := Color(1.0, 1.0, 1.0, 1.0 if active else 0.0)
	if instant:
		var _flag := tween.stop(icon)
		rect_min_size = target_size
		modulate = target_color
	else:
		Global.yes(tween.interpolate_property(self, "rect_min_size", null, target_size, 0.2, Tween.TRANS_SINE, Tween.EASE_IN_OUT))
		Global.yes(tween.interpolate_property(self, "modulate", null, target_color, 0.2))
		Global.yes(tween.start())
