extends SpinBox

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	max_value = sprite_edit.pal_data.palettes.size() - 1
	value_changed.connect(SpriteImport.set_preview_palette_index)
