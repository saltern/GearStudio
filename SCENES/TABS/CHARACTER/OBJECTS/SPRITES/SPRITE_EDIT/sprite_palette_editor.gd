extends Button

@export var palette_grid: PaletteGrid
@export var editor_panel: Control


func _ready() -> void:
	toggled.connect(on_toggled)


func on_toggled(enabled: bool) -> void:
	if enabled:
		editor_panel.show()
		palette_grid.mouse_filter = MOUSE_FILTER_STOP
	
	else:
		editor_panel.hide()
		palette_grid.mouse_filter = MOUSE_FILTER_IGNORE
