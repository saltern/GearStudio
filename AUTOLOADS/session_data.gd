# SessionData autoload
extends Node

signal load_complete
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

# New, maybe:
# tabs = [
#	{
#		"current_object": "Player",
#		"objects": {
#			0: {
#				"type": "object",
#				"data": ObjectData,
#			},
#
#			1: {
#				"type": "unsupported",
#				"data": PackedByteArray,
#			},
#		},
#	},

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


func save_bin() -> void:
	BinResource.save_resource_file(
		this_tab["data"], "C:\\users\\alt_o\\Desktop")
	
	#var bin_data: PackedByteArray = []
	#
	#for object in this_tab:
		#if this_tab[object] is ObjectData:
			#bin_data.append_array(this_tab[object].get_as_binary())
		#
		#elif this_tab[object] is PackedByteArray:
			#bin_data.append_array(this_tab[object])
	#
	#var new_file: FileAccess = FileAccess.open(
		#"C:\\Users\\alt_o\\Desktop\\test.bin", FileAccess.WRITE)
	#
	#new_file.store_buffer(bin_data)
	#new_file.close()


#region Tabs
func tab_new(path: String) -> void:
	var dir: DirAccess = DirAccess.open(path)
	
	if DirAccess.get_open_error() != OK:
		Status.set_status(
				"Could not load data! Reason: Could not open directory.")
			
		load_complete.emit.bind(path, {}).call_deferred()
		return
	
	# Build dictionary in same format as .bin loading
	
	var dir_list: PackedStringArray = dir.get_directories()
	
	if dir_list.size() < 1:
		load_complete.emit.bind(path, {}).call_deferred()
		return
	
	var new_session: Dictionary = {
		"data": {},
		"current_object": 0,
	}
	
	var dir_number: int = 0
	
	# Load objects
	for directory in dir_list:
		if directory == "palettes":
			continue
		
		var object_data := ObjectData.new()
		
		object_data.name = directory
		object_data.load_data_from_path(path + "/%s" % directory)
		
		if object_data.sprite_get_count() == 0:
			continue
		
		new_session["data"][directory] = {
			"type": "object",
			"data": object_data,
		}
	
	if not new_session["data"].is_empty():
		tabs.append(new_session)
		this_tab = new_session
		this_tab["path"] = path
	
	load_complete.emit.bind(path, new_session["data"]).call_deferred()


func tab_new_binary(path: String) -> void:
	var sub_tab_list: PackedStringArray = []
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var bin_resource: BinResource = BinResource.from_file(path)
	
	if bin_resource.objects.is_empty():
		load_complete.emit.bind(path, {}).call_deferred()
		return
	
	var new_session: Dictionary = {
		"data": {},
		"current_object": 0,
	}
	
	for object in bin_resource.objects:
		var this_object: Dictionary = bin_resource.objects[object]
		
		match this_object["type"]:
			"object":
				new_session["data"][this_object["data"].name] = this_object
			_:
				new_session["data"][object] = this_object
	
	tabs.append(new_session)
	this_tab = new_session
	this_tab["path"] = path
	
	load_complete.emit.bind(path, new_session["data"]).call_deferred()


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
	return this_tab["data"][object]["data"]
