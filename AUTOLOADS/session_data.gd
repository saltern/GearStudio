# SessionData autoload
extends Node

@warning_ignore("unused_signal")
signal tab_loading_complete
@warning_ignore("unused_signal")
signal save_complete
signal tab_closed

const serialize_ignore: Array[String] = ["path", "current_object"]

var tab_index: int = 0
var object_name: String
var tabs: Array = []
var this_tab: Dictionary = {}

# tabs = [
#	{
#		"current_object": "player",
#		"player": ObjectData,
#		"objno0": ObjectData,
#		"objno1": ObjectData,
#	},
#
#	...

func save() -> void:
	SaveErrors.reset()
	
	if this_tab.is_empty():
		Status.call_deferred("set_status", "Nothing to save.")
		GlobalSignals.call_deferred("emit_signal", "save_complete")
		return
	
	if not this_tab.has("path"):
		Status.call_deferred(\
			"set_status", "Could not save! Cause: malformed dictionary")
		GlobalSignals.call_deferred("emit_signal", "save_complete")
		return
	
	GlobalSignals.call_deferred("emit_signal", "save_start")
	Status.call_deferred("set_status", "Saving...")
	
	var save_path: String = this_tab["path"]
	
	for object in this_tab:
		if not object in serialize_ignore:
			this_tab[object].save_as_directory(save_path + "/%s" % object)

	SaveErrors.call_deferred("set_status")
	GlobalSignals.call_deferred("emit_signal", "save_complete")


#region Tabs
func tab_new(path: String) -> void:
	var sub_tab_list: PackedStringArray = []
	
	var dir: DirAccess = DirAccess.open(path)
	
	if DirAccess.get_open_error() != OK:
		Status.set_status(
				"Could not load data! Reason: Could not open directory.")
		call_deferred("emit_signal", "tab_loading_complete", path, sub_tab_list)
		return
	
	var new_session: Dictionary = {}
	var dir_list: PackedStringArray = dir.get_directories()
	
	if dir_list.size() < 1:
		call_deferred("emit_signal", "tab_loading_complete", path, sub_tab_list)
		return
	
	new_session["current_object"] = dir_list[0]
	
	# Load objects
	for directory in dir_list:
		if directory == "palettes":
			continue
		
		var object_data := ObjectData.new()
		
		object_data.name = directory
		object_data.load_data_from_path(path + "/%s" % directory)
		
		if object_data.sprites.is_empty():
			continue
		
		new_session[directory] = object_data
		sub_tab_list.append(directory)
	
	if !sub_tab_list.is_empty():
		tabs.append(new_session)
		this_tab = new_session
		this_tab["path"] = path
	
	call_deferred("emit_signal", "tab_loading_complete", path, sub_tab_list)


func tab_new_binary(path: String) -> void:
	var sub_tab_list: PackedStringArray = []
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var data: Dictionary = ResourceLoadSave.load_file(path)
	
	if data.has("error"):
		Status.set_status.call_deferred.bind(data["error"])
		return
	
	var new_session: Dictionary = {}
	
	if data.is_empty():
		call_deferred("emit_signal", "tab_loading_complete", path, sub_tab_list)
		return
	
	var obj_num: int = 0
	var aud_num: int = 0
	
	var obj_list: PackedStringArray = []
	
	for object in data:
		match data[object]["type"]:
			"player":
				data[object]["name"] = "player"
				obj_list.append("player")
			"object":
				data[object]["name"] = "objno%s" % obj_num
				obj_list.append("objno%s" % obj_num)
				obj_num += 1
			"audio_array":
				data[object]["name"] = "audio"
				obj_list.append("audioarray%s" % aud_num)
				aud_num += 1
	
	new_session["current_object"] = obj_list[0]
	
	for object in data:
		if data[object]["name"] == "audio":
			continue
		
		var object_data := ObjectData.new()	
		object_data.name = data[object]["name"]
		
		if object_data.name == "player" && data[object].has("palettes"):
			object_data.palette_data = PaletteData.new()
			object_data.palette_data.palettes = data[object]["palettes"]
		
		if data[object].has("sprites"):
			object_data.sprites = data[object]["sprites"]
		
		if data[object].has("cells"):
			object_data.cells = data[object]["cells"]
		
		if data[object].has("script"):
			object_data.script = data[object]["script"]
		
		new_session[object_data.name] = object_data
		sub_tab_list.append(object_data.name)
	
	if !sub_tab_list.is_empty():
		tabs.append(new_session)
		this_tab = new_session
		this_tab["path"] = path
	
	call_deferred("emit_signal", "tab_loading_complete", path, sub_tab_list)


func tab_load(index: int = 0) -> void:
	if index < 0 || index >= tabs.size():
		Status.set_ready()
		return
	
	tab_index = index
	this_tab = tabs[index]


func tab_close() -> void:
	if tabs.size() < 1:
		Status.set_status("Nothing currently open, can't close.")
		return
	
	tab_closed.emit(tab_index)
	tabs.remove_at(tab_index)
	this_tab = {}
	tab_load(min(tab_index, tabs.size() - 1))
	Status.set_status("Closed tab.")
#endregion


func object_data_get(object: String) -> ObjectData:
	return this_tab[object]


func palette_data_get(from_tab: int) -> PaletteData:
	if tabs[from_tab].has("palettes"):
		return tabs[from_tab]["palettes"]
	else:
		return PaletteData.new()
