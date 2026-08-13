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
	#var imp_half_size: bool = false
	#var imp_bpp: int = 8
	#var imp_reindexed: bool = true
	
	var palette: BinSprite = BinSprite.load_from_file(file, true)
	
	match import_context:
		ImportContext.SPRITES:
			FileMemory.sprite_palette_import = current_path
			#TODO: Modify import settings for sprites
			#
			#
			#
		ImportContext.PALETTES:
			FileMemory.palette_import = current_path
			palette.reindex_palette()
	
	var import_extension: String = file.get_extension().to_lower()
	
	# Transfer alpha from previous palette
	if palette == null:
		Status.set_status("STATUS_PALETTE_IMPORT_NULL")
		var array: PackedByteArray = []
		
		for i in 256:
			array.append_array([i, i, i, 0xFF])
		
		provider.palette_import(array)
		return
	
	elif import_extension == "bmp" or import_extension == "act":
		for index in palette.get_palette().size() / 4:
			palette.palette[4 * index + 3] = provider.palette_get_color(index).a8
	
	var pal_array: PackedByteArray = palette.palette.duplicate()
	provider.palette_import(pal_array)
