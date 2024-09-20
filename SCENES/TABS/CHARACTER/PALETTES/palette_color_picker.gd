extends ColorPicker

var provider: PaletteProvider


func _ready() -> void:
	provider = get_owner().get_provider()
	provider.color_selected.connect(on_color_selected)
	color = provider.palette_get_color(0)
	color_changed.connect(on_color_changed)


func on_color_selected(index: int) -> void:
	color = provider.palette_get_color(index)


func on_color_changed(new_color: Color) -> void:
	provider.palette_set_color(new_color)
