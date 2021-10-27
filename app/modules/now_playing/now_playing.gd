extends VBoxContainer

signal selected

onready var view := $TrackView
onready var progress := $ProgressBar

func _update_track(current: TrackList.Entry) -> void:
	visible = current != null
	view.entry = current
	
	if current != null:
		progress.max_value = current.value.duration
	else:
		progress.max_value = 0.001

func _ready() -> void:
	_update_track(Global.player.current)
	Global.ok(Global.player.connect("track_changed", self, "_update_track"))

func _process(_delta: float) -> void:
	progress.value = Global.player.position

func _on_TrackView_selected() -> void:
	emit_signal("selected")
