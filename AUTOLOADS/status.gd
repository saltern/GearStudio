extends Node

signal status_updated


func set_ready() -> void:
	status_updated.emit("STATUS_READY")


func set_status(string: String) -> void:
	status_updated.emit(string)


func save_status_start(dir_session: bool, path: String) -> void:
	if dir_session:
		set_status(tr("STATUS_SAVE_DIR_START").format({"path": path}))
	else:
		set_status(tr("STATUS_SAVE_BIN_START").format({"path": path}))


func save_status_end(path: String) -> void:
	set_status(tr("STATUS_SAVE_COMPLETE").format({"path": path}))
