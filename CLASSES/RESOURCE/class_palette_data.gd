class_name PaletteData extends Resource

static var default_header: PackedByteArray = [
	0x03, 0x00, 0x20, 0x00,
	0x08, 0x00, 0xC0, 0x00,
	0x20, 0x01, 0x08, 0x00,
	0x09, 0x00, 0xFF, 0xFF
]

var palettes: Array[BinPalette]


static func save_palette(pal_array: PackedByteArray, path: String) -> void:
	var act_pal: PackedByteArray = []
	var color_count: int = pal_array.size() / 4
	var extension: String = path.get_extension()
	
	if extension == "act":
		for color in color_count:
			act_pal.append(pal_array[4 * color + 0])
			act_pal.append(pal_array[4 * color + 1])
			act_pal.append(pal_array[4 * color + 2])
	
		act_pal.resize(768)
		act_pal.append_array([0x01, 0x00, 0x00, 0x00])
	
	var header: PackedByteArray = default_header.duplicate()
	
	if color_count == 16:
		header[4] = 0x04
	
	var new_file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	
	if FileAccess.get_open_error() != OK:
		return
	
	match extension:
		"bin":
			new_file.store_buffer(header)
			new_file.store_buffer(pal_array)
			new_file.close()
		
		"act":
			new_file.store_buffer(act_pal)
			new_file.close()


func serialize_and_save(path: String) -> void:	
	for palette in palettes.size():
		var this_pal: BinPalette = palettes[palette].duplicate(true)
		
		if Settings.palette_alpha_double:
			this_pal.alpha_halve()
		
		var new_file: FileAccess = FileAccess.open(
			path + "/pal_%s.bin" % palette, FileAccess.WRITE)
		
		if FileAccess.get_open_error() != OK:
			SaveErrors.palette_save_error = true
			continue
		
		new_file.store_buffer(default_header)
		new_file.store_buffer(this_pal.palette)
		new_file.close()


func load_palettes_from_path(path: String) -> void:
	palettes.clear()
	
	if DirAccess.open(path) == null:
		return
	
	# Load palettes
	for file in FileSort.get_sorted_files(path, "bin"):
		var new_palette := BinPalette.from_bin_file(file)
		
		if Settings.palette_alpha_double:
			new_palette.alpha_double()
			
		palettes.append(new_palette)
