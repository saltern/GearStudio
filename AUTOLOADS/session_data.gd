# SessionData autoload
extends Node

signal load_complete
@warning_ignore("unused_signal")
signal save_complete
signal tab_closed

const serialize_ignore: Array[String] = ["path", "current_object"]

var object_name: String
var sessions: Array = []
var session_index: int = 0
var this_session: Dictionary = {}

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
	
	if this_session.is_empty():
		Status.call_deferred("set_status", "Nothing to save.")
		GlobalSignals.call_deferred("emit_signal", "save_complete")
		return
	
	if not this_session.has("path"):
		Status.call_deferred(\
			"set_status", "Could not save! Cause: malformed dictionary")
		GlobalSignals.call_deferred("emit_signal", "save_complete")
		return
	
	GlobalSignals.call_deferred("emit_signal", "save_start")
	Status.call_deferred("set_status", "Saving...")
	
	var save_path: String = this_session["path"]
	
	for object in this_session:
		if not object in serialize_ignore:
			this_session[object].save_as_directory(save_path + "/%s" % object)

	SaveErrors.call_deferred("set_status")
	GlobalSignals.call_deferred("emit_signal", "save_complete")


func save_binary() -> void:
	Status.call_deferred("set_status", "Saving binary file...")
	BinResource.save_resource_file(this_session, "C:\\users\\alt_o\\Desktop")
	Status.call_deferred("set_status", "Save complete.")


#region Sessions
func new_directory_session(path: String) -> void:
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
		
		new_session["objects"][directory] = {
			"type": "object",
			"data": object_data,
		}
	
	if not new_session["objects"].is_empty():
		sessions.append(new_session)
		this_session = new_session
		this_session["path"] = path
	
	load_complete.emit.bind(path, new_session["objects"]).call_deferred()


func new_binary_session(path: String) -> void:
	var sub_tab_list: PackedStringArray = []
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var bin_resource: Dictionary = BinResource.from_file(path)
	
	if bin_resource.has("error"):
		Status.set_status.bind(
			"Load failed with error: %s" % bin_resource["error"]
		).call_deferred()
		return
	
	#print(bin_resource)
	
	var new_session: Dictionary = {
		"data": bin_resource,
		"current_object": 0,
	}
	
	sessions.append(new_session)
	this_session = new_session
	this_session["path"] = path
	
	load_complete.emit.bind(path, new_session).call_deferred()


func tab_load(index: int = 0) -> void:
	if index < 0 || index >= sessions.size():
		Status.set_ready()
		return
	
	session_index = index
	this_session = sessions[index]


func tab_close() -> void:
	if sessions.size() < 1:
		Status.set_status("Nothing currently open, can't close.")
		return
	
	tab_closed.emit(session_index)
	sessions.remove_at(session_index)
	this_session = {}
	tab_load(min(session_index, sessions.size() - 1))
	Status.set_status("Closed tab.")
#endregion


func object_data_get(object: int) -> Dictionary:
	return this_session["data"][object]
