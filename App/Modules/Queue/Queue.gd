extends VBoxContainer

export(Array, Texture) var queue_modes := []
export(Array, String) var queue_hints := []

onready var title: Label = $Top/Title
onready var view := $TrackListView
onready var tween: Tween = $Tween

func update_style() -> void:
	title.add_font_override("font", title.get_font("queue_title"))

func update_queue_mode(queue_mode: int) -> void:
	$Top/Mode.texture = queue_modes[queue_mode]
	$Top/Mode.hint = queue_hints[queue_mode]

func _ready() -> void:
	view.list = Global.player.queue
	
	update_style()
	Global.ok(Global.connect("theme_changed", self, "update_style"))
	
	update_queue_mode(Global.player.queue_mode)
	Global.ok(Global.player.connect("queue_mode_changed", self, "update_queue_mode"))
	
	Global.ok(Global.player.connect("track_changed", self, "_on_track_changed"))

func _exit_tree() -> void:
	Global.disconnect("theme_changed", self, "update_style")
	Global.player.disconnect("queue_mode_changed", self, "update_queue_mode")
	Global.player.disconnect("track_changed", self, "_on_track_changed")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("queue_shuffle"):
		shuffle()
	if event.is_action_pressed("queue_cycle_modes"):
		cycle_modes()

func _on_track_changed(entry: TrackList.Entry) -> void:
	view.active = entry

func shuffle() -> void:
	Global.player.queue.shuffle()

func cycle_modes() -> void:
	Global.player.queue_cycle_modes()
