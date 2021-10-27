extends "res://app/interface/list_view/list_view.gd"

signal opened(entry)

func _destroy_instance(instance) -> void:
	._destroy_instance(instance)
	instance.disconnect("selected", self, "_folder_selected")

func _create_instance(entry) -> Node:
	var instance = ._create_instance(entry)
	if instance is GDScriptFunctionState:
		instance = yield(instance, "completed")
	
	Global.ok(instance.connect("selected", self, "_folder_selected", [instance]))
	
	return instance

func update_container() -> void:
	var task = .update_container()
	if task is GDScriptFunctionState:
		yield(task, "completed")
	
	$Extra/Space.rect_min_size.y = container.rect_min_size.y

func _folder_selected(instance) -> void:
	var entry: List.Entry = instance.get(PROPERTY_ENTRY)
	emit_signal("opened", entry)
