extends "res://App/Interface/ListView/ListView.gd"

signal opened(entry)

func _get_container() -> Control:
	return $VBoxContainer/Container as Control

func _destroy_instance(instance) -> void:
	._destroy_instance(instance)
	instance.disconnect("selected", self, "_folder_selected")

func _create_instance(entry) -> Node:
	var instance = ._create_instance(entry)
	if instance is GDScriptFunctionState:
		instance = yield(instance, "completed")
	
	Global.ok(instance.connect("selected", self, "_folder_selected", [instance]))
	
	return instance

func _folder_selected(instance) -> void:
	var entry: List.Entry = instance.get(PROPERTY_ENTRY)
	emit_signal("opened", entry)
