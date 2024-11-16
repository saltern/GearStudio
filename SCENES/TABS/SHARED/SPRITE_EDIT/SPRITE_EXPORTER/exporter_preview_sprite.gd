extends TextureRect

@export var sprite_index_spinbox: SpinBox

var current_palette: PackedByteArray = SpriteExport.pal_gray

@onready var sprite_edit: SpriteEdit = owner


func _ready() -> void:
	sprite_index_spinbox.value_changed.connect(update_texture)
	
	SpriteExport.palette_include_set.connect(update_palette)
	SpriteExport.palette_index_set.connect(update_palette)
	SpriteExport.palette_alpha_mode_set.connect(update_palette)
	SpriteExport.sprite_reindex_set.connect(update_palette)
	
	update_texture(0)


func update_texture(sprite_index: int) -> void:
	#var sprite: BinSprite = sprite_edit.sprite_get(sprite_index)
	texture = sprite_edit.sprite_get_texture(sprite_index)
	
	if sprite_edit.obj_data.has_palettes():
		return
	
	update_palette()


func update_palette() -> void:
	var use_pal_state_pal: bool = false
	var this_sprite := sprite_edit.sprite_get(sprite_index_spinbox.value)
	
	current_palette = SpriteExport.pal_gray
	
	if SpriteExport.palette_include:
		if sprite_edit.obj_data.has_palettes():
			current_palette = sprite_edit.palette_get(SpriteExport.palette_index)
			current_palette = process_alpha(current_palette)
		
		elif not this_sprite.palette.is_empty():
			current_palette = this_sprite.palette
			current_palette = process_alpha(current_palette)

	current_palette = process_reindex(current_palette)
	
	material.set_shader_parameter("palette", current_palette)


func process_reindex(palette: PackedByteArray) -> PackedByteArray:
	if not SpriteExport.sprite_reindex:
		return palette
	
	if sprite_edit.sprite_get(sprite_index_spinbox.value).bit_depth == 4:
		return palette
	
	var temp_pal: PackedByteArray = []
	temp_pal.resize(1024)
	
	for index in palette.size() / 4:
		var r_index: int = index
		
		if ((r_index / 8) + 2) % 4 == 0:
			r_index -= 8
		
		elif ((r_index / 8) + 3) % 4 == 0:
			r_index += 8
		
		temp_pal[4 * r_index + 0] = palette[4 * index + 0]
		temp_pal[4 * r_index + 1] = palette[4 * index + 1]
		temp_pal[4 * r_index + 2] = palette[4 * index + 2]
		temp_pal[4 * r_index + 3] = palette[4 * index + 3]
	
	return temp_pal


func process_alpha(palette: PackedByteArray) -> PackedByteArray:
	for index in palette.size() / 4:
		var this_index: int = 4 * index + 3
		var this_alpha: int = palette[this_index]
		
		match SpriteExport.palette_alpha_mode:
			SpriteExport.AlphaMode.DOUBLE:
				palette[this_index] = min(this_alpha * 2, 0xFF)
			
			SpriteExport.AlphaMode.HALVE:
				palette[this_index] = this_alpha / 2
			
			SpriteExport.AlphaMode.OPAQUE:
				palette[this_index] = 0xFF
	
	return palette
