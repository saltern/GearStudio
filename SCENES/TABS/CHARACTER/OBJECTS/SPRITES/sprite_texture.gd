extends TextureRect

@onready var sprite_edit: SpriteEdit = get_owner()

var embedded_palette: bool = false


func _ready() -> void:
	sprite_edit.sprite_updated.connect(on_sprite_updated)
	sprite_edit.palette_updated.connect(apply_palette)
	sprite_edit.provider.palette_updated.connect(apply_palette_confirm)


func on_sprite_updated(sprite: BinSprite) -> void:
	texture = sprite.texture

	if sprite.palette.is_empty():
		embedded_palette = false
		apply_palette(sprite_edit.this_palette.palette)
		
	else:
		embedded_palette = true
		if Settings.palette_alpha_double:
			var opaque_pal: PackedByteArray = sprite.palette
			
			for index in range(1, opaque_pal.size() / 4):
				var alpha: int = 4 * index + 3
				opaque_pal[alpha] = min(0xFF, opaque_pal[alpha] * 2)
			
			material.set_shader_parameter("palette", opaque_pal)
		else:
			material.set_shader_parameter("palette", sprite.palette)
	

func apply_palette(palette: PackedByteArray) -> void:
	if embedded_palette:
		return
	
	apply_palette_confirm(palette)


func apply_palette_confirm(palette: PackedByteArray) -> void:
	material.set_shader_parameter("palette", palette)
