extends ColorPickerButton


func _ready() -> void:
	color = Settings.box_colors[Settings.BoxType.REGION]
	color_changed.connect(update)


func update(new_color: Color) -> void:
	Settings.box_colors[Settings.BoxType.REGION] = new_color
