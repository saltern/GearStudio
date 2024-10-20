extends SteppingSpinBox

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	max_value = sprite_edit.obj_data.palette_get_count() - 1
	value_changed.connect(SpriteImport.set_preview_palette_index)
