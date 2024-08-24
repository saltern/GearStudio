extends MarginContainer

@export var sprite_index: SpinBox
@export var palette_index: SpinBox
@export var sprite_node: TextureRect
@export var sprite_bounds: Control

@export var info_dimensions: Label
@export var info_color_depth: Label
@export var info_embedded_pal: Label

var palette_shader: ShaderMaterial


func _ready() -> void:
	sprite_index.value_changed.connect(update_sprite)
	palette_index.value_changed.connect(update_palette)
	palette_shader = sprite_node.material
	
	SharedData.changed_palette.connect(update_palette)
	
	if SharedData.data.sprites.size() > 0:
		sprite_index.max_value = SharedData.data.sprites.size() - 1
		update_sprite()
	
	if SharedData.data.palettes.size() > 0:
		palette_index.max_value = SharedData.data.palettes.size() - 1
		update_palette()
	

func update_sprite(new_value: int = 0) -> void:
	var new_sprite: BinSprite = SharedData.get_sprite(new_value)
	
	var tex_size: Vector2i = new_sprite.texture.get_size()
	
	sprite_node.texture = new_sprite.texture
	sprite_bounds.bounds = Rect2i(Vector2.ZERO, tex_size)
	
	info_dimensions.text = "%s x %s" % [tex_size.x, tex_size.y]
	info_color_depth.text = "%s bpp" % new_sprite.bit_depth
	info_embedded_pal.text = "No" if new_sprite.palette.is_empty() else "Yes"


func update_palette(new_palette: int = 0) -> void:
	palette_shader.set_shader_parameter(
			"palette", SharedData.data.palettes[new_palette].palette)
	
