extends CheckButton

@export var dialog: SpriteImportDialog


func _toggled(toggled_on: bool) -> void:
	dialog.set_palette_half_size(toggled_on)
