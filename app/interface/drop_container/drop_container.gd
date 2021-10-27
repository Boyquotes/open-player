tool
extends Container
class_name DropContainer

const DROP_TIME := 0.1

onready var tween: Tween = $Tween

var _position := 1.0
export var showing := false setget _set_showing
func _set_showing(value: bool) -> void:
	showing = value
	
	if not is_inside_tree():
		yield(self, "ready")
	
	var target := 0.0 if showing else 1.0
	if not Engine.editor_hint and Global.profile.animations_enabled:
		var flag1 := tween.interpolate_property(self, "_position", null, target, DROP_TIME / Global.profile.animation_speed, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		assert(flag1)
		var flag2 := tween.start()
		assert(flag2)
	else:
		_position = target

func _process(_delta: float) -> void:
	sort()

func _on_DropContainer_sort_children() -> void:
	sort()

func sort() -> void:
	for child in get_children():
		if child is Control:
			#print(name, _position < 1.0)
			child.visible = _position < 1.0
			child.rect_position = Vector2(0.0, _position * rect_size.y)
			child.rect_size = rect_size
