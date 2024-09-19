extends ColorPicker

@onready var palette_edit: PaletteEdit = get_owner()


func _ready() -> void:
	palette_edit.color_selected.connect(on_color_selected)
	color = palette_edit.palette_get_color(0)
	color_changed.connect(on_color_changed)


func on_color_selected(index: int) -> void:
	color = palette_edit.palette_get_color(index)


func on_color_changed(new_color: Color) -> void:
	palette_edit.palette_set_color(new_color)
