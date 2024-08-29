extends Node


var files_read_only: bool = false
var cell_save_error: bool = false
var palette_save_error: bool = false


func reset() -> void:
	files_read_only = false
	cell_save_error = false
	palette_save_error = false


func set_status() -> void:
	var error_string: String = ""
	
	if files_read_only:
		error_string = error_string + "Some files were read only! "
	
	if cell_save_error:
		error_string = error_string + "Could not save some cells! "
	
	if palette_save_error:
		error_string = error_string + "Could not save some palettes!"
	
	if error_string.is_empty():
		Status.set_status("Saved cells and palettes.")
	
	else:
		Status.set_status("Save had errors: %s" % error_string)
