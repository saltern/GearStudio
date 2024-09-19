extends TextureRect

var embedded_palette: bool = false
var palette_shader: ShaderMaterial = material

@onready var sprite_edit: SpriteEdit = get_owner()


func _enter_tree() -> void:
	if get_owner().get_parent().name != "player":
		material = material.duplicate()


func _ready() -> void:
	sprite_edit.sprite_updated.connect(on_sprite_updated)


func on_sprite_updated(sprite: BinSprite) -> void:
	texture = sprite.texture

	if sprite.palette.is_empty():
		embedded_palette = false
		palette_shader.set_shader_parameter(
			"palette", sprite_edit.this_palette.palette)
		
	else:
		embedded_palette = true
		
		if Settings.palette_alpha_double:
			var opaque_pal: PackedByteArray = sprite.palette
			
			for index in range(1, opaque_pal.size() / 4):
				var alpha: int = 4 * index + 3
				opaque_pal[alpha] = min(0xFF, opaque_pal[alpha] * 2)
			
			palette_shader.set_shader_parameter("palette", opaque_pal)
		else:
			palette_shader.set_shader_parameter("palette", sprite.palette)
