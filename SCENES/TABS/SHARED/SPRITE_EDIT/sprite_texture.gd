extends TextureRect

@onready var sprite_edit: SpriteEdit = get_owner()
@onready var provider: PaletteProvider = sprite_edit.provider

var embedded_palette: bool = false


func _ready() -> void:
	sprite_edit.sprite_updated.connect(on_sprite_updated)
	provider.palette_updated.connect(on_palette_updated)


func on_sprite_updated(sprite: BinSprite) -> void:
	material.set_shader_parameter("reindex", should_reindex(sprite))
	texture = sprite.texture
	apply_palette(provider.palette_get_colors())


func on_palette_updated(palette: PackedByteArray) -> void:
	apply_palette(palette)


func apply_palette(palette: PackedByteArray) -> void:
	material.set_shader_parameter("palette", palette)


func should_reindex(sprite: BinSprite) -> bool:
	if not SessionData.session_get_reindex(sprite_edit.session_id):
		return false
	
	if not sprite_edit.obj_data.has("palettes"):
		return sprite.bit_depth == 8
	
	return true
