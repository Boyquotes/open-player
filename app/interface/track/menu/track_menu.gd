extends CanvasLayer

enum {
	MENU_PLAY_NEXT,
	MENU_ADD_TO_MY_TRACKS,
	MENU_ADD_TO_FOLDER,
	MENU_EDIT,
	MENU_YOUTUBE_WATCH,
	MENU_YOUTUBE_COPY_URL,
	MENU_YOUTUBE_COPY_ID,
}

onready var menu: PopupMenu = $PopupMenu
onready var folders: PopupMenu = $PopupMenu/Lists

var entry: TrackList.Entry

func _ready() -> void:
	menu.rect_position = menu.get_global_mouse_position()
	menu.popup()
	
	### URL ###
	
	var is_youtube := entry.value.source is TrackSourceYouTube
	menu.set_item_disabled(menu.get_item_index(MENU_YOUTUBE_WATCH), not is_youtube)
	menu.set_item_disabled(menu.get_item_index(MENU_YOUTUBE_COPY_URL), not is_youtube)
	menu.set_item_disabled(menu.get_item_index(MENU_YOUTUBE_COPY_ID), not is_youtube)
	
	### LISTS ###
	
	menu.set_item_submenu(menu.get_item_index(2), "Lists")
	
	for i in Global.profile.folders.size():
		_insert_folder(Global.profile.folders.entry(i))
	
	Global.ok(Global.profile.folders.connect("inserted", self, "_insert_folder"))
	Global.ok(Global.profile.folders.connect("removed", self, "_remove_folder"))
	
	_update_folders_enabled()
	
	### CHECK AND UNCHECK ###
	
	Global.ok(entry.value.connect("list_inserted", self, "_list_inserted"))
	Global.ok(entry.value.connect("list_removed", self, "_list_removed"))
	
	_update_list_contents(Global.profile.tracks)
	for folder in Global.profile.folders.iter():
		_update_list_contents(folder)

func _insert_folder(folder_entry: List.Entry) -> void:
	folders.add_check_item("")
	_update_folders_enabled()
	
	for i in folders.get_item_count():
		_update_folder(Global.profile.folders.entry(i))
	
	Global.ok(folder_entry.value.connect("changed", self, "_update_folder", [folder_entry]))

func _remove_folder(folder_entry: List.Entry) -> void:
	folders.remove_item(folder_entry.index)
	_update_folders_enabled()
	
	folder_entry.value.disconnect("changed", self, "_update_folder")

func _update_folder(folder_entry: List.Entry) -> void:
	folders.set_item_text(folder_entry.index, folder_entry.value.title)

func _update_folders_enabled() -> void:
	menu.set_item_disabled(menu.get_item_index(2), Global.profile.folders.empty())

func _list_inserted(list: TrackList, _entry: TrackList.Entry) -> void:
	_update_list_contents(list)

func _list_removed(list: TrackList, _entry: TrackList.Entry) -> void:
	_update_list_contents(list)

func _update_list_contents(list: TrackList) -> void:
	var has := list.has(entry.value)
	if list is MyTracks:
		menu.set_item_disabled(menu.get_item_index(1), has)
	elif list is Folder:
		var index: int = Global.profile.folders.find(list)
		folders.set_item_checked(index, has)

func _on_PopupMenu_popup_hide() -> void:
	queue_free()

func _on_PopupMenu_id_pressed(id: int) -> void:
	match id:
		MENU_PLAY_NEXT:
			Global.player.queue.play_next(entry.value)
		MENU_ADD_TO_MY_TRACKS:
			Global.profile.tracks.ensure_has(entry.value)
		MENU_EDIT:
			var instance := preload("res://app/interface/track/editor/track_editor.tscn").instance()
			instance.track = entry.value
			get_tree().current_scene.add_child(instance)
		MENU_YOUTUBE_WATCH, MENU_YOUTUBE_COPY_URL, MENU_YOUTUBE_COPY_ID: # YouTube
			var source: TrackSourceYouTube = entry.value.source
			var youtube_id := source.id
			var youtube_url := "https://www.youtube.com/watch?v=%s" % youtube_id
			
			match id:
				MENU_YOUTUBE_WATCH:
					Global.ok(OS.shell_open(youtube_url))
				MENU_YOUTUBE_COPY_URL:
					OS.clipboard = youtube_url
				MENU_YOUTUBE_COPY_ID:
					OS.clipboard = youtube_id

func _on_Lists_index_pressed(index: int) -> void:
	var list: Folder = Global.profile.folders.at(index)
	
	var i := list.find(entry.value)
	if i >= 0:
		list.remove(i)
	else:
		Global.profile.tracks.ensure_has(entry.value)
		list.add(entry.value)
