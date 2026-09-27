class_name SpriteDisplay extends TextureRect

@export var standalone: bool = false
@export var pal_helper: PaletteEditorHelper
@export var selection: PaletteSelection
@export var control_sprite_index: SteppingSpinBox
@export var use_true_texture: bool = false

var session: Session
var object: BinObject
var sprite_block: BinSpriteBlock
var sprite: BinSprite

var reindex_pixels: bool = false
var reindex_palette: bool = false

var force_4bpp: bool = false
var force_8bpp: bool = false

var palette_override: bool = false
var palette: PackedByteArray = []

var shader: ShaderMaterial = material


func _ready() -> void:
	if pal_helper:
		pal_helper.sprite_updated.connect(update)
	
	if !standalone:
		session = owner.session
		object = owner.object
		session.palette_changed.connect(load_palette.unbind(1))
		
		if object is BinSpriteBlock:
			sprite_block = object
		if object is BinScriptable:
			sprite_block = object.sprites
	
	if owner is SpriteEditor:
		owner.preview_outdated.connect(update)
		owner.sprite_forced.connect(set_sprite)
		selection.selection_changed.connect(show_selection)
	
	control_sprite_index.value_changed.connect(set_sprite)
	
	set_sprite(0)


func get_current_palette() -> PackedByteArray:
	if palette_override:
		return palette
	
	if object is BinScriptable && object.has_palettes():
		return session.get_current_palette()
	else:
		if sprite == null:
			return []
		return sprite.palette
	

func set_sprite(index: int) -> void:
	index = clampi(index, 0, sprite_block.get_sprite_count() - 1)
	sprite = sprite_block.get_sprite(index)
	update()


func set_reindex_pixels(enabled: bool) -> void:
	reindex_pixels = enabled
	check_reindex()


func set_reindex_palette(enabled: bool) -> void:
	reindex_palette = enabled
	check_reindex()


func set_depth_4(enabled: bool) -> void:
	force_4bpp = enabled
	
	if enabled:
		force_8bpp = false
	
	check_bpp()


func set_depth_8(enabled: bool) -> void:
	force_8bpp = enabled
	
	if enabled:
		force_4bpp = false
	
	check_bpp()


func set_half_clut(enabled: bool) -> void:
	shader.set_shader_parameter("half_clut", enabled)


func set_alpha_double(enabled: bool) -> void:
	shader.set_shader_parameter("alpha_double", enabled)


func set_palette_override(new_palette: PackedByteArray = []) -> void:
	palette_override = !new_palette.is_empty()
	palette = new_palette
	load_palette()


func set_as_rgb(enabled: bool) -> void:
	shader.set_shader_parameter("as_rgb", enabled)
	update()


func update() -> void:
	if sprite == null:
		return
	
	elif use_true_texture:
		texture = sprite.get_texture_true()
	else:
		texture = sprite.get_texture()
	
	load_palette()
	check_reindex()
	check_bpp()


func load_palette() -> void:
	var this_pal: PackedByteArray = get_current_palette()
	shader.set_shader_parameter("palette", this_pal)
	
	if sprite == null:
		return
	
	var rgb_pal: PackedByteArray
	for i: int in sprite.palette.size() / 4:
		rgb_pal.append(sprite.palette[4 * i])
	
	shader.set_shader_parameter("palette_as_rgb", rgb_pal)


func show_selection(from: int, to: int, hover: int) -> void:
	shader.set_shader_parameter("hover_index", hover)
	shader.set_shader_parameter("selecting_min", from)
	shader.set_shader_parameter("selecting_max", to)


func check_reindex() -> void:
	shader.set_shader_parameter("reindex_palette", reindex_palette)
	
	if use_true_texture:
		shader.set_shader_parameter("reindex_pixels", reindex_pixels)
		return
	
	if sprite.bit_depth == BinSprite.DEPTH_4:
		shader.set_shader_parameter("reindex_pixels", false)
	else:
		shader.set_shader_parameter("reindex_pixels", reindex_pixels)


func check_bpp() -> void:
	shader.set_shader_parameter("force_depth_4", force_4bpp)
	shader.set_shader_parameter("force_depth_8", force_8bpp)
	shader.set_shader_parameter(
		"is_depth_4", sprite.bit_depth == BinSprite.DEPTH_4
	)
	shader.set_shader_parameter(
		"is_depth_8", sprite.bit_depth == BinSprite.DEPTH_8
	)
