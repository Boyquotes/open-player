extends Resource
class_name List

signal inserted(entry)
signal removed(entry)
signal cleared()
signal ordered(mapping)

class Entry:
	var index: int
	var value
	
	func _init(_index: int, _value):
		index = _index
		value = _value

var _entries := []
export var _contents: Array setget _set_contents
func _set_contents(value: Array) -> void:
	clear()
	for item in value:
		add(item)

func _init(contents := []):
	# See: https://github.com/godotengine/godot/issues/16478
	_contents = contents.duplicate()

# --- READ ---

func contents() -> Array:
	return _contents.duplicate()

func size() -> int:
	return _entries.size()

func empty() -> bool:
	return _entries.empty()

func entry(index: int) -> Entry:
	return _entries[index]

func at(index: int):
	return _contents[index]

func find(item) -> int:
	return _contents.find(item)

func has(item) -> bool:
	return find(item) >= 0

# --- WRITE ---

func add(item) -> void:
	insert(size(), item)

func insert(index: int, item) -> void:
	var entry := Entry.new(index, item)
	_entries.insert(index, entry)
	_contents.insert(index, item)
	
	for i in range(index + 1, _entries.size()):
		_entries[i].index = i
	
	emit_signal("inserted", entry)

func remove(index: int) -> void:
	var entry: Entry = _entries[index]
	_entries.remove(index)
	_contents.remove(index)
	
	for i in range(index, _entries.size()):
		_entries[i].index = i
	
	emit_signal("removed", entry)

func clear() -> void:
	_entries.clear()
	_contents.clear()
	
	emit_signal("cleared")

func shuffle() -> void:
	var size := size()
	var values := range(0, size)
	values.shuffle()
	
	var mapping := {}
	
	for i in size:
		mapping[i] = values[i]
	
	order(mapping)

func order(mapping: Dictionary) -> void:
	var temp_entries := {}
	var temp_contents := {}
	
	for v in mapping.values():
		temp_entries[v] = _entries[v]
		temp_contents[v] = _contents[v]
	
	for k in mapping:
		var v: int = mapping[k]
		
		var entry: Entry = temp_entries[v]
		_entries[k] = entry
		_contents[k] = temp_contents[v]
		
		entry.index = k
	
	emit_signal("ordered", mapping)

class Iterator:
	var list: List
	var i: int
	
	func _init(_list: List):
		list = _list
		i = 0
	
	func _should_continue() -> bool:
		return i < list.size()
	
	func _iter_init(_arg) -> bool:
		i = 0
		return _should_continue()
	
	func _iter_next(_arg) -> bool:
		i += 1
		return _should_continue()
	
	func _iter_get(_arg):
		return list.at(i)

func iter() -> Iterator:
	return Iterator.new(self)
