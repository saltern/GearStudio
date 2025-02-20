extends Button

@export var subviewport: SubViewport

@onready var cell_edit: CellEdit = owner


func _pressed() -> void:
	var image: Image = subviewport.get_texture().get_image()
	var used_rect: Rect2i = image.get_used_rect()
	var snapshot: Image = Image.create_empty(
		used_rect.size.x, used_rect.size.y, false, Image.FORMAT_RGBA8
	)
	
	snapshot.blit_rect(image, used_rect, Vector2i.ZERO)
	var file: String = SessionData.get_session(cell_edit.session_id)["path"].get_file()
	var date: Dictionary = Time.get_datetime_dict_from_system()
	var file_name: String = "%s_CELL-%04d" % [file, cell_edit.cell_index]
	
	file_name += "_%04d-%02d-%02d_%02d-%02d-%02d" % [
		date["year"], date["month"], date["day"],
		date["hour"], date["minute"], date["second"]
	]
	
	var path: String = OS.get_executable_path().get_base_dir()\
		 + "/snapshots/"
	
	if not DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)
	
	snapshot.save_png(path + file_name + ".png")
