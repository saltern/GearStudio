extends CheckButton


func _ready() -> void:
	button_pressed = Settings.palette_alpha_double
	toggled.connect(update)


func update(enabled: bool) -> void:
	Settings.palette_alpha_double = enabled
