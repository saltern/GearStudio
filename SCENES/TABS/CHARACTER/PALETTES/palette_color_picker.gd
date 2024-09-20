extends ColorPicker

var provider: PaletteProvider


func _ready() -> void:
	provider = get_owner().get_provider()
	provider.color_selected.connect(on_color_selected)


func on_color_selected(index: int) -> void:
	color = provider.palette_get_color(index)
