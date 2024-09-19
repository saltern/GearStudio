extends SpinBox

@onready var palette_edit: PaletteEdit = get_owner()


func _ready() -> void:
	palette_edit.palette_updated.connect(on_palette_load)
	value_changed.connect(palette_edit.palette_load)


func on_palette_load(new_palette: int) -> void:
	call_deferred("set_value_no_signal", new_palette)
