extends FileDialog

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	file_selected.connect(on_file_selected)
	close_requested.connect(hide)


func on_file_selected(file: String) -> void:
	var palette: BinPalette
	
	match file.get_extension().to_lower():
		"bin":
			palette = BinPalette.from_bin_file(file)
		
		"act":
			palette = BinPalette.from_act_file(file)
		
		"png":
			palette = BinPalette.from_png_file(file)
		
		"bmp":
			palette = BinPalette.from_bmp_file(file)

	if palette == null:
		Status.set_status(
			"Could not load palette, file is invalid or does not exist.")
		return
	
	var pal_array: PackedByteArray = palette.palette.duplicate()
	sprite_edit.provider.palette_import(pal_array)
