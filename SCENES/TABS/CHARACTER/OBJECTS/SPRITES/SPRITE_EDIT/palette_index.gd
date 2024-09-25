extends SpinBox

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	value_changed.connect(sprite_edit.palette_set)
	max_value = sprite_edit.pal_data.palettes.size() - 1
