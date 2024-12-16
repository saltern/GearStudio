extends FileDialog


func _ready() -> void:
	dir_selected.connect(register_path)


func register_path(path: String) -> void:
	FileMemory.menu_load_directory = path
