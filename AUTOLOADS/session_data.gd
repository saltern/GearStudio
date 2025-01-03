# SessionData autoload
extends Node

signal load_complete
@warning_ignore("unused_signal")
signal save_complete
signal tab_closed
signal palette_changed

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


func get_session_type() -> SessionType:
	return this_session["session_type"]


func save_directory(path: String) -> void:
	SaveErrors.reset()
	
	if path.is_empty() and this_session.has("path"):
		path = this_session["path"]
	
	if path.is_empty():
		Status.call_deferred(\
			"set_status", "Could not save! Cause: no path. Try \"Save as...\""
		)
		
		GlobalSignals.save_complete.emit.call_deferred()
		return
	
	GlobalSignals.save_start.emit.call_deferred()
	Status.set_status.call_deferred("Saving directory...")
	
	BinResource.save_resource_directory(this_session, path)

	SaveErrors.call_deferred("set_status")
	GlobalSignals.save_complete.emit.call_deferred()


func save_binary(path: String) -> void:
	if path.is_empty() and this_session.has("path"):
		path = this_session["path"]
	
	if path.is_empty():
		Status.call_deferred(\
			"set_status", "Could not save! Cause: no path. Try \"Save as...\""
		)
		
		GlobalSignals.save_complete.emit.call_deferred()
		return
	
	GlobalSignals.save_start.emit.call_deferred()
	Status.set_status.call_deferred("Saving binary file...")
	
	# Register scripts
	BinResource.save_resource_file(this_session["data"], path)
	
	Status.set_status.call_deferred("Save complete.")
	GlobalSignals.save_complete.emit.call_deferred()


#region Sessions
func new_directory_session(path: String) -> void:
	var new_session: Dictionary = {
		"session_type": SessionType.DIRECTORY,
		"current_object": 0,
		"data": BinResource.from_path(path),
	}
	
	if not new_session["data"].is_empty():
		sessions.append(new_session)
		this_session = new_session
		this_session["path"] = path
	
	load_complete.emit.bind(path, new_session).call_deferred()


func new_binary_session(path: String) -> void:
	var bin_resource: Dictionary = BinResource.from_file(path)
	
	if bin_resource.has("error"):
		Status.set_status.bind(
			"Load failed with error: %s" % bin_resource["error"]
		).call_deferred()
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


func set_palette(palette_index: int) -> void:
	palette_changed.emit(session_index, palette_index)
