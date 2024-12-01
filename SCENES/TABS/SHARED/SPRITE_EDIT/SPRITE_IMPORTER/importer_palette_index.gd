extends SteppingSpinBox

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	if sprite_edit.obj_data.has("palettes"):
		max_value = sprite_edit.obj_data["palettes"].size() - 1
	
	value_changed.connect(SpriteImport.set_preview_palette_index)
