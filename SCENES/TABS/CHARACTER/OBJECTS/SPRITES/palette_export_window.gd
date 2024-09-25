extends FileDialog

@onready var provider: PaletteProvider = get_owner().provider


func _ready() -> void:
	file_selected.connect(on_file_selected)


func on_file_selected(path: String) -> void:
	PaletteData.save_palette(provider.palette_get_colors(), path)
