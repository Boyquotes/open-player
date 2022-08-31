tool
extends GridContainer

enum Type {
	Main,
	Cross,
}

export(Type) var type: int

export var target_path: NodePath = "."
onready var target := get_node_or_null(target_path) as Control

func _ready() -> void:
	_update()
	Global.ok(target.connect("item_rect_changed", self, "_on_item_rect_changed"))

func _update() -> void:
	var main := int(target.rect_size.aspect() < 1.0) == type
	columns = get_child_count() if main and get_child_count() > 0 else 1

func _on_item_rect_changed() -> void:
	_update()
