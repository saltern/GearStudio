extends ColorPickerButton


func _ready() -> void:
	color = Settings.cell_onion_skin
	color_changed.connect(update)


func update(new_color: Color) -> void:
	Settings.cell_onion_skin = new_color
	Settings.onion_color_changed.emit()
