extends TextureRect

@export var sprite_index: SpinBox

var obj_state: ObjectEditState
var pal_state: PaletteEditState


func _ready() -> void:
	sprite_index.max_value = obj_state.data.sprites.size() - 1
	sprite_index.value_changed.connect(update_sprite)
	pal_state.changed_palette.connect(update_palette)
	
	update_sprite(0)
	update_palette()


func update_sprite(new_index: int) -> void:
	texture = obj_state.data.sprites[new_index].texture


func update_palette() -> void:
	material.set_shader_parameter("palette", pal_state.get_palette_colors())
