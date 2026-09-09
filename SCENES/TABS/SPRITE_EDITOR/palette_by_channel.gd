extends CheckButton

@export var pal_helper: PaletteEditorHelper


func _toggled(toggled_on: bool) -> void:
	pal_helper.by_channel = toggled_on
