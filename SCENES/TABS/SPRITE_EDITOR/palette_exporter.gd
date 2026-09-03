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
			current_path = FileMemory.sprite_palette_export
		Context.PALETTE_EDITOR:
			current_path = FileMemory.palette_export
	
	file_selected.connect(on_file_selected)
	close_requested.connect(hide)


func on_file_selected(path: String) -> void:
	match context:
		Context.SPRITE_EDITOR:
			FileMemory.sprite_palette_export = current_path
		Context.PALETTE_EDITOR:
			FileMemory.palette_export = current_path
	
	var contents: PackedByteArray = []
	
	match path.get_extension():
		"bin":
			var sprite: BinSprite = pal_helper.sprite.duplicate()
			sprite.mode = BinSprite.Mode.PALETTE
			contents = sprite.serialize()
		
		"act":
			var rgb: PackedByteArray
			var pal: PackedByteArray = pal_helper.sprite.palette
			pal.resize(4 * 256)
			
			for index: int in 256:
				rgb.append(pal[4 * index + 0])
				rgb.append(pal[4 * index + 1])
				rgb.append(pal[4 * index + 2])
			
			contents.append_array(rgb)
			contents.append(0x01)
			contents.append(0x00)
			contents.append(0x00)
			contents.append(0x00)

	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_buffer(contents)
	file.close()
