extends Label


func _ready() -> void:
	SpriteImport.files_selected.connect(on_files_selected)


func on_files_selected() -> void:
	if not visible:
		return
	
	text = "Will import %s sprites." % SpriteImport.import_list.size()
	text = tr("SPRITE_EDIT_IMPORT_FILES_COUNT").format({
		"count": SpriteImport.import_list.size()
	})
