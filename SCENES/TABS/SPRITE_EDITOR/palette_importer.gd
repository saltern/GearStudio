extends FileDialog

enum Context {
	SPRITE_EDITOR,
	PALETTE_EDITOR,
}

@export var context: Context
@export var pal_helper: PaletteEditorHelper


func _ready() -> void:
	match context:
		Context.SPRITE_EDITOR:
			current_path = FileMemory.sprite_palette_import
		Context.PALETTE_EDITOR:
			current_path = FileMemory.palette_import
		
	file_selected.connect(on_file_selected)
	close_requested.connect(hide)


func on_file_selected(path: String) -> void:
	match context:
		Context.SPRITE_EDITOR:
			FileMemory.sprite_palette_import = current_path
		Context.PALETTE_EDITOR:
			FileMemory.palette_import = current_path
	
	if path.get_extension() == "act":
		import_act(path)
		return
	
	var sprite: BinSprite = BinSprite.load_from_file(path, true)
	
	if not sprite.has_palette():
		Status.set_status("<LOCALIZE>: Imported file has no palette")
	else:
		pal_helper.import(sprite.palette)


func import_act(path: String) -> void:
	var sprite: BinSprite = pal_helper.sprite
	
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var colors: PackedByteArray = sprite.palette.duplicate()
	colors.resize(4 * pal_helper.get_color_count())
	
	for index: int in pal_helper.get_color_count():
		colors[4 * index + 0] = file.get_8()
		colors[4 * index + 1] = file.get_8()
		colors[4 * index + 2] = file.get_8()
	
	colors = BinSprite.transform_rgba_array(colors)
	pal_helper.import(colors)
