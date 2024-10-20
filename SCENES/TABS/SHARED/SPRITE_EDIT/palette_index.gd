extends SteppingSpinBox

@onready var sprite_edit: SpriteEdit = get_owner()
@onready var provider: PaletteProvider = sprite_edit.provider


func _ready() -> void:
	if not sprite_edit.obj_data.has_palettes():
		get_parent().queue_free()
		return
	
	max_value = sprite_edit.obj_data.palette_get_count() - 1
	value_changed.connect(change_palette)
	provider.obj_data.palette_selected.connect(external_update_value)


func change_palette(index: int) -> void:
	provider.palette_load(index)
	provider.obj_data.palette_broadcast(index)


func external_update_value(index: int) -> void:
	call_deferred("set_value_no_signal", index)
	provider.palette_load(index)
