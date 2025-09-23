extends CheckButton


func _ready() -> void:
	button_pressed = Settings.cell_draw_origin
	toggled.connect(on_toggle)


func on_toggle(enabled: bool) -> void:
	Settings.set_cell_draw_origin(enabled)
