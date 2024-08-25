class_name PaletteEditState extends Resource

signal changed_palette

var palettes: Array[BinPalette]
var palette_index: int = 0
var this_palette: BinPalette


func load_palettes_from_path(path: String) -> void:
	palettes.clear()
	
	if DirAccess.open(path) == null:
		return
	
	# Load palettes
	for file in FileSort.get_sorted_files(path, "bin"):
		palettes.append(BinPalette.from_file(file))


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
	this_palette.palette[4 * index + 0] = color.r8
	this_palette.palette[4 * index + 1] = color.g8
	this_palette.palette[4 * index + 2] = color.b8
	this_palette.palette[4 * index + 3] = color.a8
	
	changed_palette.emit()
