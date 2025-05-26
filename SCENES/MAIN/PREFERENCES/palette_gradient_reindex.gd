extends CheckButton


func _ready() -> void:
	button_pressed = Settings.pal_gradient_reindex
	toggled.connect(on_toggle)


func on_toggle(enabled: bool) -> void:
	Settings.pal_gradient_reindex = enabled
