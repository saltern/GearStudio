extends SpinBox

@onready var palette_edit: PaletteEdit = get_owner()
@onready var provider: PaletteProvider = palette_edit.provider


func _ready() -> void:
	max_value = provider.pal_data.palettes.size() - 1
	provider.palette_imported.connect(on_palette_imported)
	value_changed.connect(provider.palette_load)


func on_palette_imported(index: int) -> void:
	call_deferred("set_value_no_signal", index)
