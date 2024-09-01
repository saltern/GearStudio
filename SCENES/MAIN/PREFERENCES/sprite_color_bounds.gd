extends ColorPickerButton


func _ready() -> void:
	color = Settings.sprite_color_bounds
	color_changed.connect(update)


func update(new_color: Color) -> void:
	Settings.sprite_color_bounds = new_color
