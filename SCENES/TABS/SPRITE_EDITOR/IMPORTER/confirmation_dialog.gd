extends ConfirmationDialog

@export var dialog: SpriteImportDialog


func _ready() -> void:
	dialog.files_set.connect(on_files_set)
	confirmed.connect(dialog.process_sprites)
	confirmed.connect(hide)
	canceled.connect(hide)


func on_files_set(files: PackedStringArray) -> void:
	dialog_text = tr("SPRITE_EDIT_IMPORT_CONFIRM_TEXT").format(
		{"count": files.size()}
	)
