extends ColorPickerButton


func _ready() -> void:
	color = Settings.cell_guide
	color_changed.connect(update)


func update(new_color: Color) -> void:
	Settings.set_cell_guide_color(new_color)
