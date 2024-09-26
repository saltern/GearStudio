extends ColorPickerButton


func _ready() -> void:
	color = Settings.custom_color_status
	color_changed.connect(update)


func update(new_color: Color) -> void:
	Settings.custom_color_status = new_color
	Settings.custom_color_status_changed.emit()
