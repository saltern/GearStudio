extends SpinBox


func _ready() -> void:
	SpriteImport.files_selected.connect(on_files_selected)
	value_changed.connect(SpriteImport.set_preview_index)


func on_files_selected() -> void:
	max_value = SpriteImport.import_list.size() - 1
	value = 0
	
