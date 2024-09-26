extends TextureRect

@onready var sprite_edit: SpriteEdit = get_owner()
@onready var provider: PaletteProvider = sprite_edit.provider

var embedded_palette: bool = false


func _ready() -> void:
	sprite_edit.sprite_updated.connect(on_sprite_updated)
	provider.palette_updated.connect(on_palette_updated)


func on_sprite_updated(sprite: BinSprite) -> void:
	texture = sprite.texture
	apply_palette(provider.palette_get_colors_fallback())


func on_palette_updated(palette: PackedByteArray) -> void:
	apply_palette(palette)
	on_sprite_updated(provider.sprite)


func apply_palette(palette: PackedByteArray) -> void:
	material.set_shader_parameter("palette", palette)
