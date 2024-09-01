extends Node

var opened_paths: Array[String] = []


func path_open(path: String) -> void:
	opened_paths.append(path)


func path_close(index: int) -> void:
	opened_paths.remove_at(index)


func path_is_open(path: String) -> bool:
	if path in opened_paths:
		return true
	
	else:
		return false
