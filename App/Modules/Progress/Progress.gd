extends HBoxContainer
class_name Progress

onready var start_label := $Start
onready var end_label := $End
onready var progress_bar := $ProgressBar

func _update_duration(entry: TrackList.Entry) -> void:
	if entry != null:
		progress_bar.max_value = entry.value.duration
	else:
		progress_bar.max_value = 0.001

func _ready() -> void:
	_update_duration(Global.player.current)
	Global.ok(Global.player.connect("track_changed", self, "_update_duration"))

func _process(_delta: float) -> void:
	progress_bar.value = Global.player.position
	start_label.text = Global.display_time(progress_bar.value)
	end_label.text = Global.display_time(progress_bar.max_value)

func _on_ProgressBar_gui_input(event: InputEvent) -> void:
	var target_position
	
	if event is InputEventMouseButton:
		if event.pressed:
			target_position = event.position.x
			Global.player.seeking = true
		else:
			Global.player.seeking = false
	if event is InputEventMouseMotion:
		if event.button_mask & BUTTON_LEFT:
			target_position = event.position.x
	
	if target_position != null:
		Global.player.position = target_position / progress_bar.rect_size.x * progress_bar.max_value
