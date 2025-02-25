extends TextureRect

@onready var sprite_edit: SpriteEdit = get_owner()
@onready var provider: PaletteProvider = sprite_edit.provider

var embedded_palette: bool = false


func _ready() -> void:
	sprite_edit.sprite_updated.connect(on_sprite_updated)
	provider.palette_updated.connect(on_palette_updated)


func on_sprite_updated(sprite: BinSprite) -> void:
	if not sprite_edit.obj_data.has("name") or \
	sprite_edit.obj_data.name != "player":
		material.set_shader_parameter("reindex", sprite.bit_depth == 8)
	
	texture = sprite.texture
	apply_palette(provider.palette_get_colors())


func on_palette_updated(palette: PackedByteArray) -> void:
	apply_palette(palette)


func apply_palette(palette: PackedByteArray) -> void:
	material.set_shader_parameter("palette", palette)
