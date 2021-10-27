extends "res://app/interface/list_view/list_view.gd"

export var playable := true

func _destroy_instance(instance) -> void:
	._destroy_instance(instance)
	instance.disconnect("removed", self, "_track_removed")

func _create_instance(entry) -> Node:
	var instance = ._create_instance(entry)
	if instance is GDScriptFunctionState:
		instance = yield(instance, "completed")
	
	instance.playable = playable
	instance.removable = editable
	
	Global.ok(instance.connect("removed", self, "_track_removed", [instance]))
	
	return instance

func _track_removed(instance) -> void:
	var entry: List.Entry = instance.get(PROPERTY_ENTRY)
	list.remove(entry.index)
