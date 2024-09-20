extends SpinBox

@onready var palette_edit: PaletteEdit = get_owner()

var provider: PaletteProvider


func _ready() -> void:
	provider = get_owner().get_provider()
	value_changed.connect(provider.palette_load)
	max_value = provider.pal_data.palettes.size() - 1
