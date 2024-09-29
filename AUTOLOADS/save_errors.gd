extends Node


var files_read_only: bool = false
var cell_save_error: bool = false
var sprite_save_error: bool = false
var palette_save_error: bool = false


func reset() -> void:
	files_read_only = false
	cell_save_error = false
	sprite_save_error = false
	palette_save_error = false


func set_status() -> void:
	var err_string: String = ""
	
	if files_read_only:
		err_string = err_string + "Some files were read only! "
	
	if cell_save_error:
		err_string = err_string + "Could not save some cells! "
	
	if sprite_save_error:
		err_string = err_string + "Could not save some sprites! "
	
	if palette_save_error:
		err_string = err_string + "Could not save some palettes!"
	
	if err_string.is_empty():
		Status.set_status("Saved cells, sprites, and palettes.")
	
	else:
		Status.set_status("Save had errors: %s" % err_string)
