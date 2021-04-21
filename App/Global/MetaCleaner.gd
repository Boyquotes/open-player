extends Node

func _compile(strings: Array) -> Array:
	var arr := []
	for s in strings:
		var regex := RegEx.new()
		Global.ok(regex.compile(s))
		arr.push_back(regex)
	return arr

onready var _strip_channel := _compile([
])

onready var _strip_title := _compile([
	"(?i) \\(.*\\)$",
	"(?i) \\[.*\\]$"
])

func _strip_all(s: String, regexes: Array) -> String:
	while true:
		var original := s
		for regex in regexes:
			s = regex.sub(s, "", true)
		if original == s:
			break
	return s

func strip_channel(channel: String) -> String:
	return _strip_all(channel, _strip_channel)

func strip_title(title: String) -> String:
	return _strip_all(title, _strip_title)
