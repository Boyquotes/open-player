extends List
class_name TrackList

var _track_keys := []

func _init():
	Global.ok(connect("inserted", self, "_on_inserted"))
	Global.ok(connect("removed", self, "_on_removed"))
	Global.ok(connect("cleared", self, "_on_cleared"))
	Global.ok(connect("ordered", self, "_on_ordered"))

func _on_inserted(entry: Entry) -> void:
	_track_keys.insert(entry.index, entry.value.key())
	entry.value.emit_signal("list_inserted", self, entry)

func _on_removed(entry: Entry) -> void:
	_track_keys.remove(entry.index)
	entry.value.emit_signal("list_removed", self, entry)

func _on_cleared() -> void:
	_track_keys.clear()

func _on_ordered(mapping: Dictionary) -> void:
	var temp_keys := {}
	
	for v in mapping.values():
		temp_keys[v] = _track_keys[v]
	
	for k in mapping:
		var v: int = mapping[k]
		
		_track_keys[k] = temp_keys[v]

func find(track: Track) -> int:
	return _track_keys.find(track.key())

func ensure_has(track: Track) -> Entry:
	if not has(track):
		.add(track)
	
	return entry(find(track))

func ensure_at(index: int, track: Track) -> Entry:
	var old_index := find(track)
	
	if old_index >= 0:
		if index > old_index:
			index -= 1
		
		var mapping := {}
		var step := sign(old_index - index)
		for i in range(index, old_index, step):
			mapping[i + step] = i
		
		mapping[index] = old_index
		
		order(mapping)
	else:
		.insert(index, track)
	
	return entry(index)
