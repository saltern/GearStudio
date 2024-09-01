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


func _init() -> void:
	undo.max_steps = Settings.misc_max_undo


func serialize_and_save(path: String) -> void:	
	for palette in palettes.size():
		var this_pal: BinPalette = palettes[palette].duplicate(true)
		if Settings.palette_alpha_double:
			this_pal.alpha_halve()
		
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
		if Settings.palette_alpha_double:
			new_palette.alpha_double()
		palettes.append(new_palette)


func load_palette(number: int = 0) -> void:
	palette_index = number
	this_palette = palettes[palette_index]
	changed_palette.emit(number)


func get_palette_colors(palette: int = 0) -> PackedByteArray:
	return palettes[palette].palette


func get_color(index: int = 0) -> Color:
	return Color8(
		this_palette.palette[4 * index + 0],
		this_palette.palette[4 * index + 1],
		this_palette.palette[4 * index + 2],
		this_palette.palette[4 * index + 3])


func get_color_in(index: int = 0, palette: int = 0) -> Color:
	return Color8(
		palettes[palette].palette[4 * index + 0],
		palettes[palette].palette[4 * index + 1],
		palettes[palette].palette[4 * index + 2],
		palettes[palette].palette[4 * index + 3])


func set_color(selected: Array[bool], color: Color) -> void:
	undo.create_action("Palette #%s set color(s)" % palette_index)
	
	var old_palette: PackedByteArray = this_palette.palette.duplicate()
	var new_palette: PackedByteArray = this_palette.palette.duplicate()
	
	for cell in 256:
		if !selected[cell]:
			continue
		
		new_palette[4 * cell + 0] = color.r8
		new_palette[4 * cell + 1] = color.g8
		new_palette[4 * cell + 2] = color.b8
		new_palette[4 * cell + 3] = color.a8
	
	undo.add_do_property(this_palette, "palette", new_palette)
	undo.add_do_method(load_palette.bind(palette_index))
	
	undo.add_undo_property(this_palette, "palette", old_palette)
	undo.add_undo_method(load_palette.bind(palette_index))
	
	undo.commit_action()


func paste_color(at_index: int) -> void:
	var old_palette: PackedByteArray = this_palette.palette.duplicate()
	var new_palette: PackedByteArray = this_palette.palette.duplicate()
	
	var start_index: int = 0
	var current_color: int = 0
	
	for cell in 256:
		if Clipboard.pal_selection[cell]:
			start_index = cell
			break
	
	if at_index < 0 || at_index > 255:
		return
	
	for cell in 256:
		var this_index: int = at_index - start_index + cell
		
		if !Clipboard.pal_selection[cell]:
			continue
		
		if this_index < 0 || this_index > 255:
			continue
		
		new_palette[4 * this_index + 0] = Clipboard.pal_data[current_color].r8
		new_palette[4 * this_index + 1] = Clipboard.pal_data[current_color].g8
		new_palette[4 * this_index + 2] = Clipboard.pal_data[current_color].b8
		new_palette[4 * this_index + 3] = Clipboard.pal_data[current_color].a8
		
		current_color += 1
	
	paste_color_commit(old_palette, new_palette)


func paste_color_into(selection: Array[bool]) -> void:
	var current_color: int = 0
	
	var old_palette: PackedByteArray = this_palette.palette.duplicate()
	var new_palette: PackedByteArray = this_palette.palette.duplicate()
	
	for cell in 256:
		if !selection[cell]:
			continue
		
		new_palette[4 * cell + 0] = Clipboard.pal_data[current_color].r8
		new_palette[4 * cell + 1] = Clipboard.pal_data[current_color].g8
		new_palette[4 * cell + 2] = Clipboard.pal_data[current_color].b8
		new_palette[4 * cell + 3] = Clipboard.pal_data[current_color].a8
		
		current_color = wrapi(current_color + 1, 0, Clipboard.pal_data.size())
	
	paste_color_commit(old_palette, new_palette)
	

func paste_color_commit(old: PackedByteArray, new: PackedByteArray) -> void:
	undo.create_action("Palette #%s paste color(s)" % palette_index)
	
	undo.add_do_property(this_palette, "palette", new)
	undo.add_do_method(load_palette.bind(palette_index))
	
	undo.add_undo_property(this_palette, "palette", old)
	undo.add_undo_method(load_palette.bind(palette_index))
	
	undo.commit_action()
