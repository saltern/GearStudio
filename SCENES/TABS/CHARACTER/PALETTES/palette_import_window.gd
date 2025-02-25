extends FileDialog

@export var summon_button: Button

@onready var provider: PaletteProvider = get_owner().provider


func _ready() -> void:
	summon_button.pressed.connect(display)
	file_selected.connect(on_file_selected)
	close_requested.connect(hide)


func display() -> void:
	if visible:
		return
	
	current_path = FileMemory.palette_import
	show()


func on_file_selected(file: String) -> void:
	FileMemory.palette_import = current_path
	
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
	provider.palette_import(pal_array)
