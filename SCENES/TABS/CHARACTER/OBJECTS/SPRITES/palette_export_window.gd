extends FileDialog

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	file_selected.connect(on_file_selected)


func on_file_selected(path: String) -> void:
	PaletteData.save_palette(sprite_edit.provider.sprite.palette, path)
