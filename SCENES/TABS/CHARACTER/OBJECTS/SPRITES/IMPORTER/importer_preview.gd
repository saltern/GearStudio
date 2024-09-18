extends TextureRect

var gray_pal: PackedInt32Array


func _ready() -> void:
	for index in 256:
		gray_pal.append_array([index, index, index, 0xFF])
	
	SpriteImport.preview_generated.connect(update_preview)


func update_preview(sprite: BinSprite) -> void:
	if sprite == null:
		texture = null
	else:
		texture = sprite.texture
		if sprite.palette.is_empty():
			material.set_shader_parameter("palette", gray_pal)
		else:
			var palette: PackedByteArray = sprite.palette
			
			for color in palette.size() / 4:
				palette[4 * color + 3] = min(palette[4 * color + 3] * 2, 0xFF)
			
			material.set_shader_parameter("palette", palette)
