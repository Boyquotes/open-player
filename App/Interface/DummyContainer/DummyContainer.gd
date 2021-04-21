tool
extends PanelContainer
class_name DummyContainer

func _init():
	mouse_filter = MOUSE_FILTER_PASS
	add_stylebox_override("panel", StyleBoxEmpty.new())
