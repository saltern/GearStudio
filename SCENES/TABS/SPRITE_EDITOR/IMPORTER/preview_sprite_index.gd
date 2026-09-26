extends SteppingSpinBox

@export var dialog: SpriteImportDialog


func _ready() -> void:
	dialog.files_set.connect(on_files_set)
	max_value = 0


func on_files_set(files: PackedStringArray) -> void:
	max_value = files.size() - 1
