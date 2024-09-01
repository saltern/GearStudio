extends ColorPickerButton


func _ready() -> void:
	color = Settings.box_colors[Settings.BoxType.HURTBOX]
	color_changed.connect(update)


func update(new_color: Color) -> void:
	Settings.box_colors[Settings.BoxType.HURTBOX] = new_color
