extends Label

@export var file_dialog: FileDialog


func _ready() -> void:
	file_dialog.files_selected.connect(on_files_selected)


func on_files_selected(files: PackedStringArray) -> void:
	text = tr("SPRITE_EDIT_IMPORT_FILES_COUNT").format({
		"count": files.size()
	})
