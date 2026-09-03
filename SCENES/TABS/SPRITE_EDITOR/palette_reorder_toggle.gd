extends Button


@export var selection_manager: PaletteSelection


func _toggled(toggled_on: bool) -> void:
	selection_manager.visible = toggled_on
	selection_manager.reorder_mode = toggled_on
