extends DummyContainer

onready var queue_container: DropContainer = $QueueContainer
onready var queue := queue_container.get_node("Queue")

func _ready() -> void:
	Global.ok(Global.connect("go_back", self, "_on_go_back"))

func _on_go_back(request: Global.GoBackRequest) -> void:
	if queue_container.showing:
		queue_container.showing = false
		request.exit = false

func _on_NowPlaying_selected() -> void:
	queue_container.showing = true

func _on_Drop_pressed() -> void:
	queue_container.showing = false
