extends HBoxContainer
class_name Controls

export(Array, Texture) var volume_stages := []

onready var play_pause := $PlayPause
onready var previous_track := $Left/HBoxContainer/PreviousTrack
onready var next_track := $Right/HBoxContainer/NextTrack
onready var seek_back := $Left/HBoxContainer/SeekBack
onready var seek_forward := $Right/HBoxContainer/SeekForward
onready var volume := $Left/HBoxContainer/Volume
onready var speed := $Right/HBoxContainer/SpeedOption

func _ready() -> void:
	_update_style()
	Global.ok(Global.profile.connect("theme_changed", self, "_update_style"))
	
	_update_volume(Global.profile.volume)
	Global.ok(Global.profile.connect("volume_changed", self, "_update_volume"))
	
	_update_speed(Global.player.speed)
	Global.ok(Global.player.connect("speed_changed", self, "_update_speed"))

func _update_style() -> void:
	speed.add_stylebox_override("normal", speed.get_stylebox("control_button_normal"))
	speed.add_stylebox_override("hover", speed.get_stylebox("control_button_hover"))
	speed.add_stylebox_override("pressed", speed.get_stylebox("control_button_pressed"))

func _update_volume(value: float) -> void:
	volume.get_node("Popup/PanelContainer/VSlider").value = value
	
	var stage := ceil(value * 3.0)
	volume.texture = volume_stages[stage]

func _update_speed(value: float) -> void:
	speed.text = str(value) + "x"

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		match event.scancode:
			KEY_MEDIAPREVIOUS:
				Global.player.previous_track()
			KEY_MEDIAPLAY, KEY_MEDIASTOP:
				Global.player.toggle_playing()
			KEY_MEDIANEXT:
				Global.player.next_track(true)
	if event.is_action_pressed("previous_track", true):
		Global.player.previous_track()
	if event.is_action_pressed("next_track", true):
		Global.player.next_track(true)
	if event.is_action_pressed("skip_backward", true):
		Global.player.position -= 30.0 if Input.is_action_pressed("skip_modifier") else 5.0
	if event.is_action_pressed("skip_forward", true):
		Global.player.position += 30.0 if Input.is_action_pressed("skip_modifier") else 5.0
	if event.is_action_pressed("toggle_playing", true):
		Global.player.toggle_playing()

func _popup_above(button: Button, popup: Popup) -> void:
	popup.rect_position = button.rect_global_position + Vector2.RIGHT * (button.rect_size.x - popup.rect_size.x) / 2.0 + Vector2.UP * popup.rect_size.y
	popup.popup()

func _on_Volume_pressed() -> void:
	_popup_above(volume, volume.get_node("Popup"))

func _on_VSlider_value_changed(value: float) -> void:
	Global.profile.volume = value

func _on_SpeedOption_pressed() -> void:
	_popup_above(speed, speed.get_node("PopupMenu"))

func _on_PopupMenu_index_pressed(index) -> void:
	var popup: PopupMenu = speed.get_node("PopupMenu")
	for i in popup.get_item_count():
		popup.set_item_checked(i, i == index)
	
	var speed_array := [
		0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0
	]
	Global.player.speed = speed_array[index]
