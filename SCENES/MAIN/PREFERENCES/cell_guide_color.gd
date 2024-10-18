extends ColorPickerButton


func _ready() -> void:
	color = Settings.cell_guide
	color_changed.connect(update)


func update(new_color: Color) -> void:
	Settings.cell_guide = new_color
	Settings.guide_color_changed.emit()
