extends TextureRect

@export var sprite_index: SpinBox

var obj_state: ObjectEditState
var pal_state: PaletteEditState


func _ready() -> void:
	material = get_owner().palette_shader
	
	obj_state = SessionData.object_state_get("player")
	pal_state = SessionData.palette_state_get(
		get_owner().get_parent().get_index())
	
	sprite_index.max_value = obj_state.data.sprites.size() - 1
	sprite_index.value_changed.connect(update_sprite)
	pal_state.changed_palette.connect(on_palette_load)
	
	update_sprite(0)
	on_palette_load(pal_state.palette_index)


func update_sprite(new_index: int) -> void:
	texture = obj_state.data.sprites[new_index].texture


func on_palette_load(new_palette: int = 0) -> void:
	material.set_shader_parameter("palette", pal_state.get_palette_colors(
		new_palette))


func update_palette() -> void:
	on_palette_load(pal_state.palette_index)
