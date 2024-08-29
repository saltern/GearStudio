class_name PaletteEditState extends Resource

signal changed_palette

var default_header: PackedByteArray = [
	0x03, 0x00, 0x20, 0x00,
	0x08, 0x00, 0xC0, 0x00,
	0x20, 0x01, 0x08, 0x00,
	0x09, 0x00, 0xFF, 0xFF
]

var undo: UndoRedo = UndoRedo.new()
var palettes: Array[BinPalette]
var palette_index: int = 0
var this_palette: BinPalette


func serialize_and_save(path: String) -> void:	
	for palette in palettes.size():
		var this_pal: BinPalette = palettes[palette].duplicate(true)
		this_pal.alpha_halve()
		this_pal.reindex()
		
		var new_file: FileAccess = FileAccess.open(
				path + "/pal_%s.bin" % palette,
				FileAccess.WRITE)
		
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
		var new_palette := BinPalette.from_file(file)
		new_palette.alpha_double()
		new_palette.reindex()
		palettes.append(new_palette)


func load_palette(number: int = 0) -> void:
	palette_index = number
	this_palette = palettes[palette_index]
	changed_palette.emit()


func get_palette_colors() -> PackedByteArray:
	return this_palette.palette


func get_color(index: int = 0) -> Color:
	return Color8(
		this_palette.palette[4 * index + 0],
		this_palette.palette[4 * index + 1],
		this_palette.palette[4 * index + 2],
		this_palette.palette[4 * index + 3])


func set_color(index: int, color: Color) -> void:
	undo.create_action("Palette #%s set color #%s" % [palette_index, index])
	
	var old_color: Color = Color8(
		this_palette.palette[4 * index + 0],
		this_palette.palette[4 * index + 1],
		this_palette.palette[4 * index + 2],
		this_palette.palette[4 * index + 3])
	
	undo.add_do_method(set_color_commit.bind(palette_index, index, color))
	undo.add_undo_method(set_color_commit.bind(palette_index, index, old_color))
	
	undo.commit_action()


func set_color_commit(pal_index: int, index: int, color: Color) -> void:
	load_palette(pal_index)
	
	this_palette.palette[4 * index + 0] = color.r8
	this_palette.palette[4 * index + 1] = color.g8
	this_palette.palette[4 * index + 2] = color.b8
	this_palette.palette[4 * index + 3] = color.a8
	
	changed_palette.emit()
