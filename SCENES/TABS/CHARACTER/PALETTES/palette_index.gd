extends SpinBox

@onready var palette_edit: PaletteEdit = get_owner()
@onready var provider: PaletteProvider = palette_edit.provider


func _ready() -> void:
	max_value = palette_edit.palette_get_count() - 1
	
	palette_edit.obj_data.palette_selected.connect(external_change_palette)
	provider.palette_imported.connect(external_update_value)
	
	value_changed.connect(change_palette)


func change_palette(index: int) -> void:
	provider.palette_load(index)
	provider.obj_data.palette_broadcast(index)


func external_update_value(index: int) -> void:
	call_deferred("set_value_no_signal", index)


func external_change_palette(index: int) -> void:
	external_update_value(index)
	provider.palette_load(index)
