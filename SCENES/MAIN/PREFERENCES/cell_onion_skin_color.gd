extends ColorPickerButton


func _ready() -> void:
	color = Settings.cell_onion_skin
	color_changed.connect(update)


func update(new_color: Color) -> void:
	Settings.set_cell_onion_skin_color(new_color)
