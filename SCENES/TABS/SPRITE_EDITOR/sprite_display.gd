class_name SpriteDisplay extends TextureRect

@export var pal_helper: PaletteEditorHelper
@export var selection: PaletteSelection
@export var sprite_index: SteppingSpinBox
@export var use_true_texture: bool = false

var session: Session
var object: BinObject
var sprite_block: BinSpriteBlock
var sprite: BinSprite

var reindex: bool = false

var force_4bpp: bool = false
var force_8bpp: bool = false

var palette_override: bool = false
var palette: PackedByteArray = []


func _ready() -> void:
	pal_helper.sprite_updated.connect(update)
	
	session = owner.session
	object = owner.object
	
	if owner is SpriteEditor:
		owner.preview_outdated.connect(update)
		selection.selection_changed.connect(show_selection)
	
	session.palette_changed.connect(load_palette.unbind(1))
	sprite_index.value_changed.connect(set_sprite)
	
	if object is BinSpriteBlock:
		sprite_block = object
	if object is BinScriptable:
		sprite_block = object.sprites
	
	set_sprite(0)


func get_current_palette() -> PackedByteArray:
	if palette_override:
		return palette
	
	if object is BinScriptable && object.has_palettes():
		return session.get_current_palette()
	else:
		return sprite.palette
	

func set_sprite(index: int) -> void:
	index = clampi(index, 0, sprite_block.get_sprite_count() - 1)
	sprite = sprite_block.get_sprite(index)
	update()


func set_reindex(enabled: bool) -> void:
	reindex = enabled
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
	(material as ShaderMaterial).set_shader_parameter(
		"half_clut", enabled
	)


func set_palette_override(new_palette: PackedByteArray = []) -> void:
	palette_override = !new_palette.is_empty()
	palette = new_palette
	load_palette()


func update() -> void:
	if use_true_texture:
		texture = sprite.get_true_texture()
	else:
		texture = sprite.get_texture()
	
	load_palette()
	check_reindex()
	check_bpp()


func load_palette() -> void:
	(material as ShaderMaterial).set_shader_parameter(
		"palette", get_current_palette()
	)


func show_selection(from: int, to: int, hover: int) -> void:
	(material as ShaderMaterial).set_shader_parameter(
		"hover_index", hover
	)
	
	(material as ShaderMaterial).set_shader_parameter(
		"selecting_min", from
	)
	
	(material as ShaderMaterial).set_shader_parameter(
		"selecting_max", to
	)


func check_reindex() -> void:
	if use_true_texture:
		material.set_shader_parameter("reindex", reindex)
		return
	
	if sprite.bit_depth == BinSprite.DEPTH_4:
		material.set_shader_parameter("reindex", false)
	else:
		material.set_shader_parameter("reindex", reindex)


func check_bpp() -> void:
	(material as ShaderMaterial).set_shader_parameter(
		"force_depth_4", force_4bpp
	)
	(material as ShaderMaterial).set_shader_parameter(
		"force_depth_8", force_8bpp
	)
	(material as ShaderMaterial).set_shader_parameter(
		"is_depth_4", sprite.bit_depth == BinSprite.DEPTH_4
	)
	(material as ShaderMaterial).set_shader_parameter(
		"is_depth_8", sprite.bit_depth == BinSprite.DEPTH_8
	)
