extends ColorPickerButton


func _ready() -> void:
	color = Settings.box_colors[Settings.BoxType.UNKNOWN]
	color_changed.connect(update)


func update(new_color: Color) -> void:
	Settings.box_colors[Settings.BoxType.UNKNOWN] = new_color
	Settings.box_colors[Settings.BoxType.UNKNOWN_2] = new_color
