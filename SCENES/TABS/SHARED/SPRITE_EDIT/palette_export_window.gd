extends FileDialog

@onready var provider: PaletteProvider = get_owner().provider


func _ready() -> void:
	file_selected.connect(on_file_selected)


func on_file_selected(path: String) -> void:
	match path.get_extension():
		"bin":
			#provider.palette.to_bin_file(path)
			provider.palette.to_act_file(path)
		"act":
			provider.palette.to_act_file(path)
