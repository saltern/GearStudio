extends Node

signal undo_redo_changed
signal version_changed
signal show_window

var undo: UndoRedo


func set_undo_redo(undo_redo: UndoRedo) -> void:
	# Old undo
	if undo != null:
		undo.version_changed.disconnect(on_version_changed)
	
	undo = undo_redo
	undo_redo_changed.emit()
	
	# New undo
	undo.version_changed.connect(on_version_changed)


func on_version_changed() -> void:
	version_changed.emit()


func get_action(index: int) -> String:
	return undo.get_action_name(index)


func get_most_recent_action() -> String:
	return undo.get_current_action_name()


func get_action_count() -> int:
	return undo.get_history_count()


func get_version() -> int:
	return undo.get_version() - 1


func set_version(version: int) -> void:
	var difference: int = get_version() - version
	
	if difference > 0:
		for _i in range(0, difference):
			undo.undo()
	elif difference < 0:
		for _i in range(0, -difference):
			undo.redo()


func display() -> void:
	show_window.emit()
