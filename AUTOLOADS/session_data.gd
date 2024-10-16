# SessionData autoload
extends Node

@warning_ignore("unused_signal")
signal tab_loading_complete
@warning_ignore("unused_signal")
signal save_complete
signal tab_closed

var tab_index: int = 0
var object_name: String
var tabs: Array = []
var this_tab: Dictionary = {}

var serialize_ignore: Array[String] = ["path", "current_object", "palettes"]

# tabs = [
#	{
#		"current_object": "player",
#		"palettes": PaletteEditState,
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
		if object in serialize_ignore:
			continue
		
		this_tab[object].serialize_and_save(save_path + "/%s" % object)
	
	if this_tab.has("palettes"):
		this_tab["palettes"].serialize_and_save(save_path + "/palettes")

	SaveErrors.call_deferred("set_status")
	GlobalSignals.call_deferred("emit_signal", "save_complete")


#region Tabs
func tab_new(path: String) -> void:
	var sub_tab_list: PackedStringArray = []
	
	var dir: DirAccess = DirAccess.open(path)
	
	if DirAccess.get_open_error() != OK:
		Status.set_status(
				"Could not load character! Reason: Could not open directory.")
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
		
		# Load palettes as subresource of ObjectData...
		if dir.dir_exists("palettes") and directory == "player":
			object_data.load_palette_data_from_path(path + "/palettes")
		
		if dir.dir_exists("%s/sprites" % directory):
			object_data.load_sprites_from_path(path + "/%s/sprites" % directory)
		
		if dir.dir_exists("%s/cells" % directory):
			object_data.load_cells_from_path(path + "/%s/cells" % directory)
		
		#if dir.file_exists("%s/script.json" % directory):
			#object_data.load_script_from_file(path + "/%s/script.json" % directory)
		
		if object_data.sprites.is_empty() and object_data.cells.is_empty():
			continue
		
		new_session[directory] = object_data
		sub_tab_list.append(directory)
	
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


func tab_close(index: int = 0) -> void:
	if tabs.size() < 1:
		Status.set_status("Nothing currently open, can't close.")
		return
	
	tab_closed.emit(index)
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
