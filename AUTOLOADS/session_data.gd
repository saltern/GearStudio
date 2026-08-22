# SessionData autoload
extends Node

signal load_complete
signal tab_closed
@warning_ignore("unused_signal")
signal tab_reset_session_ids	# Emitted by session_tabs.gd
signal palette_changed
@warning_ignore("unused_signal")
signal sprite_reindexed			# Emitted by SpriteEdit's PaletteProvider
signal sprite_palette_changed
signal refresh_previews

#const serialize_ignore: Array[String] = ["path", "current_object"]

var sessions: Array[Session] = []
var session_index: int = 0
var this_session: Session


#func save_directory(path: String) -> void:
	#SaveErrors.reset()
	#
	#if path.is_empty() and this_session.has("path"):
		#path = this_session["path"]
	#
	#if path.is_empty():
		#Status.call_deferred(\
			#"set_status", "STATUS_SAVE_DIR_PATH_ERROR"
		#)
		#
		#GlobalSignals.save_complete.emit.call_deferred()
		#return
	#
	#GlobalSignals.save_start.emit.call_deferred()
	#Status.save_status_start.call_deferred(true, path)
	#
	#BinResource.save_resource_directory(this_session, path, GlobalSignals)
#
	#SaveErrors.call_deferred("set_status", path)
	#GlobalSignals.save_complete.emit.call_deferred()


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
	
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_buffer(get_current_session().archive.serialize())
	
	Status.save_status_end.call_deferred(path)
	GlobalSignals.save_complete.emit.call_deferred()


#region Sessions
func get_session(index: int) -> Session:
	return sessions[index]


func get_current_session() -> Session:
	return get_session(session_index)


func get_session_type() -> Session.Type:
	return this_session.type


func get_session_count() -> int:
	return sessions.size()


#func new_directory_session(path: String) -> void:
	#var new_session: Dictionary = {
		#"session_type": SessionType.DIRECTORY,
		#"current_object": 0,
		#"data": BinResource.from_path(path, ScriptInstructions.INSTRUCTION_DB),
	#}
	#
	#new_session["reindex"] = Settings.general_reindex_mode
	#
	#if not new_session["data"].is_empty():
		#sessions.append(new_session)
		#this_session = new_session
		#this_session["path"] = path
	#
	#load_complete.emit.bind(path, new_session).call_deferred()


func new_binary_session(path: String) -> void:
	var session: Session = Session.new(path)
	session.type = Session.Type.BINARY
	sessions.append(session)
	
	this_session = session
	
	# Add session-wide reference to palette data
	# Palettes should always be under object 0 (player)
	var object: BinObject = this_session.get_object(0)
	
	if object is BinScriptable && object.has_palettes():
		this_session.palettes = object.palettes
	
	load_complete.emit.bind(session).call_deferred()


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
	
	sessions.remove_at(session_index)
	tab_closed.emit(session_index)
	Status.set_status("STATUS_TAB_CLOSE")
	tab_load(min(session_index, sessions.size() - 1))
#endregion


func object_data_get(object: int) -> Dictionary:
	return this_session["data"][object]


func set_palette(palette_index: int) -> void:
	palette_changed.emit(session_index, palette_index)


# Called by PaletteProvider
func set_sprite_palette(obj_data: Dictionary, sprite_index: int) -> void:
	sprite_palette_changed.emit(session_index, obj_data, sprite_index)


func session_set_reindex(session_id: int, enabled: bool) -> void:
	var session: Session = get_session(session_id)
	session.reindex_mode = enabled
	refresh_previews.emit(session_id)


# Called by script_cell_sprite_display.gd
func session_get_palettes(session_id: int) -> Array[BinSprite]:
	if not session_has_palettes(session_id):
		return []
	else:
		return get_session(session_id).palettes.sprites


func session_get_reindex(session_id: int) -> bool:
	var session: Session = get_session(session_id)
	return session.reindex_mode


func session_has_palettes(session_id: int) -> bool:
	return get_session(session_id).has_palettes()
