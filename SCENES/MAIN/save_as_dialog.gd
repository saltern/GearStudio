extends FileDialog


func _ready() -> void:
	file_selected.connect(register_path)


func register_path(path: String) -> void:
	FileMemory.menu_save_as = path
	FileMemory.menu_load_binary = path
