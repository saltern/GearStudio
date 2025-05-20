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


func set_status(path: String) -> void:
	var err_string: String = ""
	
	if files_read_only:
		err_string = err_string + "STATUS_SAVE_DIR_ERROR_READ_ONLY" + " "
	
	if cell_save_error:
		err_string = err_string + "STATUS_SAVE_DIR_ERROR_CELLS" + " "
	
	if sprite_save_error:
		err_string = err_string + "STATUS_SAVE_DIR_ERROR_SPRITES" + " "
	
	if palette_save_error:
		err_string = err_string + "STATUS_SAVE_DIR_ERROR_PALETTES"
	
	if err_string.is_empty():
		Status.set_status(
			tr("STATUS_SAVE_COMPLETE").format({"path": path})
		)
	
	else:
		Status.set_status(
			tr("STATUS_SAVE_DIR_ERROR").format({
				"errors": err_string
			})
		)
