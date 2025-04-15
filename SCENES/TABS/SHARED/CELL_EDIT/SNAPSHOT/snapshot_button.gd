extends Button

@export var box_display_toggle: CheckButton
# I don't like this any more than you do
@export var origin_textures: Array[Texture2D] = []

@onready var cell_edit: CellEdit = owner


func _pressed() -> void:
	# Generate filename, path
	var file: String = \
		SessionData.get_session(cell_edit.session_id)["path"].get_file()
	var date: Dictionary = Time.get_datetime_dict_from_system()
	var file_name: String = "%s_CELL-%04d" % [file, cell_edit.cell_index]
	
	file_name += "_%04d-%02d-%02d_%02d-%02d-%02d" % [
		date["year"], date["month"], date["day"],
		date["hour"], date["minute"], date["second"]
	]
	
	var path: String = OS.get_executable_path().get_base_dir()\
		 + "/snapshots/"
	
	# Create path for first time save
	if not DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)
	
	# Snapshot data...
	var cell: Cell = cell_edit.this_cell
	var pal: PackedByteArray
	
	# Global/local pal
	if cell_edit.obj_data.has("palettes"):
		pal = cell_edit.obj_data.palettes[0].palette
	else:
		pal = cell_edit.obj_data.sprites[cell.sprite_index].palette
	
	# Origin cross
	var origin: PackedByteArray = []
	
	# Boxes visible at all?
	var box_display_types: Array[bool] = []
	box_display_types.resize(7)
	
	if box_display_toggle.button_pressed:
		box_display_types = cell_edit.box_display_types
	
	if Settings.cell_draw_origin:
		var this_tex: Texture2D = origin_textures[Settings.cell_origin_type]
		# Tex width/height
		origin.append(this_tex.get_width())
		# Pixels
		origin.append_array(this_tex.get_image().get_data())
	
	
	# Options 0 and 2: PNG
	if Settings.cell_snapshot_format % 2 == 0:
		# Save
		cell.save_snapshot_png(
			# Sprite
			cell_edit.obj_data.sprites[cell.sprite_index], pal, false,
			# Boxes
			box_display_types,
			Settings.box_colors,
			Settings.box_thickness,
			# Origin cross
			origin,
			# Save path
			path + file_name + ".png"
		)
	
	# Options 1 and 2: PSD
	if Settings.cell_snapshot_format > 0:
		# Save
		cell.save_snapshot_psd(
			# Sprite
			cell_edit.obj_data.sprites[cell.sprite_index], pal, false,
			# Boxes
			box_display_types,
			Settings.box_colors,
			Settings.box_thickness,
			# Origin cross
			origin,
			# Save path
			path + file_name + ".psd"
		)
