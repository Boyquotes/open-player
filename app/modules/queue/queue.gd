extends VBoxContainer

export(Array, Texture) var queue_modes := []
export(Array, String) var queue_hints := []

onready var title := $Top/Title
onready var shuffle := $Top/Shuffle
onready var mode := $Top/Mode

onready var view := $TrackListView
onready var tween: Tween = $Tween

func _update_style() -> void:
	title.add_font_override("font", title.get_font("queue_title"))
	shuffle.add_color_override("icon", Color.white)
	mode.add_color_override("icon", Color.white)

func _update_queue_mode(queue_mode: int) -> void:
	mode.texture = queue_modes[queue_mode]
	mode.hint = queue_hints[queue_mode]

func _ready() -> void:
	view.list = Global.player.queue
	
	_update_style()
	Global.ok(Global.profile.connect("theme_changed", self, "_update_style"))
	
	_update_queue_mode(Global.player.queue_mode)
	Global.ok(Global.player.connect("queue_mode_changed", self, "_update_queue_mode"))
	
	Global.ok(Global.player.connect("track_changed", self, "_on_track_changed"))

func _exit_tree() -> void:
	Global.profile.disconnect("theme_changed", self, "_update_style")
	Global.player.disconnect("queue_mode_changed", self, "_update_queue_mode")
	Global.player.disconnect("track_changed", self, "_on_track_changed")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("queue_shuffle"):
		Global.player.queue.shuffle()
	if event.is_action_pressed("queue_cycle_modes"):
		Global.player.queue_cycle_modes()

func _on_track_changed(entry: TrackList.Entry) -> void:
	view.active = entry

func _on_Shuffle_pressed() -> void:
	Global.player.queue.shuffle()

func _on_Mode_pressed() -> void:
	Global.player.queue_cycle_modes()
