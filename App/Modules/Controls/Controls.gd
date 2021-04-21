extends HBoxContainer
class_name Controls

export(Array, Texture) var volume_stages := []

func _ready() -> void:
	_update_style()
	Global.ok(Global.connect("theme_changed", self, "_update_style"))
	
	_update_volume()
	Global.ok(Global.profile.connect("volume_changed", self, "_update_volume"))
	
	_update_speed(Global.player.speed)
	Global.ok(Global.player.connect("speed_changed", self, "_update_speed"))

func _update_style() -> void:
	var button: Button = $SpeedOption
	button.add_stylebox_override("normal", button.get_stylebox("control_button_normal"))
	button.add_stylebox_override("hover", button.get_stylebox("control_button_hover"))
	button.add_stylebox_override("pressed", button.get_stylebox("control_button_pressed"))

func _update_volume(_value = null) -> void:
	$Volume/Popup/PanelContainer/VSlider.value = Global.profile.volume
	
	var stage := ceil(Global.profile.volume * 3.0)
	$Volume.texture = volume_stages[stage]

func _update_speed(speed: float) -> void:
	$SpeedOption.text = str(speed) + "x"

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
	if event.is_action_pressed("skip_backward", true):
		Global.player.position -= 30.0 if Input.is_action_pressed("skip_modifier") else 5.0
	if event.is_action_pressed("toggle_playing", true):
		Global.player.toggle_playing()
	if event.is_action_pressed("skip_forward", true):
		Global.player.position += 30.0 if Input.is_action_pressed("skip_modifier") else 5.0
	if event.is_action_pressed("next_track", true):
		Global.player.next_track(true)

func _popup_above(button: Button, popup: Popup) -> void:
	popup.rect_position = button.rect_global_position + Vector2.RIGHT * (button.rect_size.x - popup.rect_size.x) / 2.0 + Vector2.UP * popup.rect_size.y
	popup.popup()

func _on_Volume_pressed() -> void:
	_popup_above($Volume, $Volume/Popup)

func _on_VSlider_value_changed(value: float) -> void:
	Global.profile.volume = value

func _on_SpeedOption_pressed() -> void:
	_popup_above($SpeedOption, $SpeedOption/PopupMenu)

func _on_PopupMenu_index_pressed(index) -> void:
	var popup: PopupMenu = $SpeedOption/PopupMenu
	for i in popup.get_item_count():
		popup.set_item_checked(i, i == index)
	
	var speed_array := [
		0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0
	]
	Global.player.speed = speed_array[index]
