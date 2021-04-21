extends TabContainer

const FADE_TIME := 0.05

onready var tween: Tween = $Tween

func _ready() -> void:
	_update_active_view()
	Global.ok(Global.player.connect("active_view_changed", self, "_update_active_view"))

func _update_active_view(_active_view = null) -> void:
	if Global.profile.animations_enabled:
		Global.yes(tween.stop_all())
		Global.yes(tween.interpolate_property(self, "modulate", null, Color.transparent, FADE_TIME / Global.profile.animation_speed))
		Global.yes(tween.start())
		yield(tween, "tween_all_completed")
	
	var view = Global.player.active_view
	
	match view:
		"home":
			current_tab = 0
		"import":
			current_tab = 1
		"tracks":
			current_tab = 2
		"folders":
			current_tab = 3
		"settings":
			current_tab = 4
	
	if Global.profile.animations_enabled:
		modulate = Color.transparent
		Global.yes(tween.interpolate_property(self, "modulate", null, Color.white, FADE_TIME / Global.profile.animation_speed))
		Global.yes(tween.start())
	else:
		modulate = Color.white
