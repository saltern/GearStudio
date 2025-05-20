# SessionData autoload
extends Node

signal load_complete
#signal save_complete
signal tab_closed
@warning_ignore("unused_signal")
signal tab_reset_session_ids	# Emitted by session_tabs.gd
signal palette_changed
signal sprite_reindexed			# Emitted by SpriteEdit's PaletteProvider

enum SessionType {
	DIRECTORY,
	BINARY,
}

const serialize_ignore: Array[String] = ["path", "current_object"]

var object_name: String
var sessions: Array = []
var session_index: int = 0
var this_session: Dictionary = {}

# sessions = [
#	{
#		"current_object": 0,
#		"session_type": "directory",
#		"data": {
#			0: {
#				"type": "scriptable",
#				"data": {
#					"cells": Array[Cell],
#					"sprites": Array[BinSprite],
#					"scripts": PackedByteArray,
#					"palettes": Array[BinPalette],
#				},
#			},
#
#			1: {
#				"type": "unsupported",
#				"data": PackedByteArray,
#			},
#		},
#	},
#	...


func save_directory(path: String) -> void:
	SaveErrors.reset()
	
	if path.is_empty() and this_session.has("path"):
		path = this_session["path"]
	
	if path.is_empty():
		Status.call_deferred(\
			"set_status", "STATUS_SAVE_DIR_PATH_ERROR"
		)
		
		GlobalSignals.save_complete.emit.call_deferred()
		return
	
	GlobalSignals.save_start.emit.call_deferred()
	Status.save_status_start.call_deferred(true, path)
	
	BinResource.save_resource_directory(this_session, path, GlobalSignals)

	SaveErrors.call_deferred("set_status", path)
	GlobalSignals.save_complete.emit.call_deferred()


func save_binary(path: String) -> void:
	if path.is_empty() and this_session.has("path"):
		path = this_session["path"]
	
	if path.is_empty():
		Status.call_deferred(\
			"set_status", "STATUS_SAVE_BIN_PATH_ERROR"
		)
		
		GlobalSignals.save_complete.emit.call_deferred()
		return
	
	GlobalSignals.save_start.emit.call_deferred()
	Status.save_status_start.call_deferred(false, path)
	
	BinResource.save_resource_file(this_session["data"], path, GlobalSignals)
	
	Status.save_status_end.call_deferred(path)
	GlobalSignals.save_complete.emit.call_deferred()


#region Sessions
func get_session(index: int) -> Dictionary:
	return sessions[index]


func get_current_session() -> Dictionary:
	return get_session(session_index)


func get_session_type() -> SessionType:
	return this_session["session_type"]


func get_session_count() -> int:
	return sessions.size()


func new_directory_session(path: String) -> void:
	var new_session: Dictionary = {
		"session_type": SessionType.DIRECTORY,
		"current_object": 0,
		"data": BinResource.from_path(path, ScriptInstructions.INSTRUCTION_DB),
	}
	
	if not new_session["data"].is_empty():
		sessions.append(new_session)
		this_session = new_session
		this_session["path"] = path
	
	load_complete.emit.bind(path, new_session).call_deferred()


func new_binary_session(path: String) -> void:
	var bin_resource: Dictionary = BinResource.from_file(
		path, ScriptInstructions.INSTRUCTION_DB
	)
	
	if bin_resource.has("error"):
		binary_load_error.bind(bin_resource["error"]).call_deferred()
		return
	
	var new_session: Dictionary = {
		"session_type": SessionType.BINARY,
		"current_object": 0,
		"data": bin_resource,
	}
	
	sessions.append(new_session)
	this_session = new_session
	this_session["path"] = path
	
	load_complete.emit.bind(path, new_session).call_deferred()


func binary_load_error(error: String) -> void:
	Status.set_status(tr("STATUS_LOAD_BIN_ERROR").format({"error": error}))


func tab_load(index: int = 0) -> void:
	if index < 0 || index >= sessions.size():
		Status.set_ready()
		return
	
	session_index = index
	this_session = sessions[index]


func tab_close() -> void:
	if sessions.size() < 1:
		Status.set_status("STATUS_NOTHING_OPEN_CANT_CLOSE")
		return
	
	#tab_closed.emit(session_index)
	sessions.remove_at(session_index)
	this_session = {}
	tab_closed.emit(session_index)
	tab_load(min(session_index, sessions.size() - 1))
	Status.set_status("STATUS_TAB_CLOSE")
#endregion


func object_data_get(object: int) -> Dictionary:
	return this_session["data"][object]


func set_palette(palette_index: int) -> void:
	palette_changed.emit(session_index, palette_index)
