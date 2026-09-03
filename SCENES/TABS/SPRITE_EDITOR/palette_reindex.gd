extends Button

@export var pal_helper: PaletteEditorHelper


func _pressed() -> void:
	pal_helper.reindex()
