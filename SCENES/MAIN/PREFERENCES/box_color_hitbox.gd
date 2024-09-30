extends ColorPickerButton


func _ready() -> void:
	color = Settings.box_colors[Settings.BoxType.HITBOX]
	color_changed.connect(update)


func update(new_color: Color) -> void:
	Settings.box_colors[Settings.BoxType.HITBOX] = new_color
	Settings.box_colors[Settings.BoxType.HITBOX_ALT] = new_color
