extends FileDialog

enum ImportContext {
	SPRITES,
	PALETTES,
}

@export var import_context: ImportContext
@export var summon_button: Button

@onready var provider: PaletteProvider = get_owner().provider


func _ready() -> void:
	summon_button.pressed.connect(display)
	file_selected.connect(on_file_selected)
	close_requested.connect(hide)


func display() -> void:
	if visible:
		return
	
	match import_context:
		ImportContext.SPRITES:
			current_path = FileMemory.sprite_palette_import
		ImportContext.PALETTES:
			current_path = FileMemory.palette_import
	
	show()


func on_file_selected(file: String) -> void:
	# Default for player character palettes
	var imp_half_size: bool = false
	var imp_bpp: int = 8
	var imp_reindexed: bool = true
	
	match import_context:
		ImportContext.SPRITES:
			FileMemory.sprite_palette_import = current_path
			#TODO: Modify import settings for sprites
			#
			#
			#
		ImportContext.PALETTES:
			FileMemory.palette_import = current_path
	
	var import_extension: String = file.get_extension().to_lower()
	var palette: BinPalette
	
	match import_extension:
		"bin":
			palette = BinPalette.from_bin_file(file)
		
		"act":
			palette = BinPalette.from_act_file(file, imp_half_size, imp_bpp, imp_reindexed)
		
		"png":
			palette = BinPalette.from_png_file(file, imp_reindexed)
		
		"bmp":
			palette = BinPalette.from_bmp_file(file, imp_reindexed)
	
	# Transfer alpha from previous palette
	if import_extension == "bmp" or import_extension == "act":
		for index in palette.palette.size() / 4:
			palette.palette[4 * index + 3] = provider.palette_get_color(index).a8
		
	if palette == null:
		Status.set_status("STATUS_PALETTE_IMPORT_NULL")
		return
	
	var pal_array: PackedByteArray = palette.palette.duplicate()
	provider.palette_import(pal_array)
