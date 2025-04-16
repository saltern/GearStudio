extends ColorPicker

var provider: PaletteProvider
var last_index: int


func _ready() -> void:
	SessionData.palette_changed.connect(update_palette.unbind(2))
	provider = get_owner().get_provider()


func on_color_selected(index: int) -> void:
	last_index = index
	color = provider.palette_get_color(index)


func update_palette() -> void:
	on_color_selected(last_index)
