extends Node

signal status_updated


func set_ready() -> void:
	status_updated.emit("Ready.")


func set_status(string: String) -> void:
	status_updated.emit(string)
