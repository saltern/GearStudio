class_name SpriteDisplay extends TextureRect

@export var pal_helper: PaletteEditorHelper
@export var selection: PaletteSelection
@export var sprite_index: SteppingSpinBox

var session: Session
var object: BinObject
var sprite_block: BinSpriteBlock
var sprite: BinSprite

var reindex: bool = false


func _ready() -> void:
	pal_helper.sprite_updated.connect(update)
	selection.selection_changed.connect(on_selection_changed)
	
	session = owner.session
	object = owner.object
	
	if owner is SpriteEditor:
		owner.preview_outdated.connect(update)
	
	session.palette_changed.connect(load_palette.unbind(1))
	sprite_index.value_changed.connect(set_sprite)
	
	if object is BinSpriteBlock:
		sprite_block = object
	if object is BinScriptable:
		sprite_block = object.sprites
	
	set_sprite(0)


func get_current_palette() -> PackedByteArray:
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
	reindex_check()


func update() -> void:
	texture = sprite.get_texture()
	load_palette()
	reindex_check()


func load_palette() -> void:
	(material as ShaderMaterial).set_shader_parameter(
		"palette", get_current_palette()
	)


func on_selection_changed() -> void:
	(material as ShaderMaterial).set_shader_parameter(
		"hover_index", selection.hover
	)
	
	(material as ShaderMaterial).set_shader_parameter(
		"selecting_min", selection.selecting_min
	)
	
	(material as ShaderMaterial).set_shader_parameter(
		"selecting_max", selection.selecting_max
	)


func reindex_check() -> void:
	if sprite.bit_depth == BinSprite.DEPTH_4:
		material.set_shader_parameter("reindex", false)
	else:
		material.set_shader_parameter("reindex", reindex)
