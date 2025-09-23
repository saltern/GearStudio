extends ColorPickerButton


func _ready() -> void:
	color = Settings.custom_color_bg_b
	color_changed.connect(update)


func update(new_color: Color) -> void:
	Settings.set_custom_color_bg_b(new_color)
