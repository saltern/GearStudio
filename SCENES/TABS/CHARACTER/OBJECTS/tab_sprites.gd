extends MarginContainer

@export var sprite_index: SpinBox
@export var palette_index: SpinBox
@export var sprite_node: TextureRect
@export var sprite_bounds: Control

@export var info_dimensions: Label
@export var info_color_depth: Label
@export var info_embedded_pal: Label

var palette_shader: ShaderMaterial

var embedded_pal: bool = false

@onready var pal_state: PaletteEditState = SessionData.get_palette_state(
	get_parent().get_parent().get_index())

@onready var obj_state: ObjectEditState = SessionData.get_object_state(
	get_parent().name)


func _ready() -> void:
	sprite_index.value_changed.connect(update_sprite)
	palette_index.value_changed.connect(update_palette)
	palette_shader = sprite_node.material
	
	pal_state.changed_palette.connect(update_palette)
	
	if obj_state.data.sprites.size() > 0:
		sprite_index.max_value = obj_state.data.sprites.size() - 1
		update_sprite()
	

func update_sprite(new_value: int = 0) -> void:	
	var new_sprite: BinSprite = obj_state.get_sprite(new_value)
	
	var tex_size: Vector2i = new_sprite.texture.get_size()
	
	sprite_node.texture = new_sprite.texture
	
	if !new_sprite.palette.is_empty():
		embedded_pal = true
		palette_index.editable = false
		
		var opaque_pal: PackedByteArray = new_sprite.palette
		
		for color_index in range(1, opaque_pal.size() / 4):
			var new_alpha: int = opaque_pal[4 * color_index + 3]
			new_alpha = min(0xFF, new_alpha * 2)
			opaque_pal[4 * color_index + 3] = new_alpha
		
		palette_shader.set_shader_parameter("palette", opaque_pal)
	
	else:
		embedded_pal = false
		palette_index.editable = true
		update_palette(palette_index.value)
	
	sprite_bounds.bounds = Rect2i(Vector2.ZERO, tex_size)
	
	info_dimensions.text = "%s x %s" % [tex_size.x, tex_size.y]
	info_color_depth.text = "%s bpp" % new_sprite.bit_depth
	info_embedded_pal.text = "No" if new_sprite.palette.is_empty() else "Yes"


func update_palette(new_palette: int = 0) -> void:
	if embedded_pal:
		return
		
	if pal_state.palettes.size() > new_palette:
		palette_shader.set_shader_parameter(
				"palette", pal_state.palettes[new_palette].palette)
	
