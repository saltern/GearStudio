extends Node

signal status_updated


func set_ready() -> void:
	status_updated.emit("STATUS_READY")


func set_status(string: String) -> void:
	status_updated.emit(string)
