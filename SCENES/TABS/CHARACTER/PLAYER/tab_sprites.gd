extends MarginContainer

@export var sprite_index: SpinBox
@export var palette_index: SpinBox
@export var sprite_node: TextureRect
@export var sprite_bounds: Control

var palette_shader: ShaderMaterial

var data: CharacterData


func _ready() -> void:
	sprite_index.value_changed.connect(update_sprite)
	palette_index.value_changed.connect(update_palette)
	palette_shader = sprite_node.material
	
	if data.sprites.size() > 0:
		sprite_index.max_value = data.sprites.size() - 1
		update_sprite()
	
	if data.palettes.size() > 0:
		palette_index.max_value = data.palettes.size() - 1
		update_palette()
	

func update_sprite(new_value: int = 0) -> void:	
	sprite_node.texture = data.sprites[new_value].texture
	sprite_bounds.bounds = Rect2i(
			Vector2.ZERO,
			sprite_node.texture.get_size()
	)


func update_palette(new_value: int = 0) -> void:
	palette_shader.set_shader_parameter(
			"palette", data.palettes[new_value].palette)
