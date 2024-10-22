class_name CellSpriteDisplay extends Control

var obj_data: ObjectData

var sprite_index: int = 0
var palette_index: int = 0


func _enter_tree() -> void:
	if get_owner().get_parent().name != "player":
		material = material.duplicate()
	
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func load_cell(cell: Cell) -> void:
	if cell.sprite_info.index < obj_data.sprite_get_count():
		sprite_index = cell.sprite_info.index
		load_cell_sprite(sprite_index, cell.boxes)
	
	else:
		unload_sprite()
		
	position = cell.sprite_info.position


func unload_sprite() -> void:
	for child in get_children():
		child.queue_free()


func load_cell_sprite(index: int, boxes: Array[BoxInfo]) -> void:
	unload_sprite()
	
	var cutout_list: Array[Rect2i] = []
	var offset_list: Array[Vector2i] = []
	
	# Type 6 crops appear in front of type 3 crops, add them later
	# (Thanks Athenya)
	for type in [3, 6]:
		for box in boxes:
			if box.type != type: continue
			
			var offset_x: int = 8 * box.crop_x_offset
			var offset_y: int = 8 * box.crop_y_offset
			
			offset_list.append(Vector2i(offset_x, offset_y))
			cutout_list.append(box.rect)
	
	load_cell_sprite_pieces(index, cutout_list, offset_list)
	material.set_shader_parameter("palette", get_palette(index))


func load_cell_sprite_pieces(
	index: int, rects: Array[Rect2i], offsets: Array[Vector2i]
) -> void:
	var sprite: BinSprite = obj_data.sprite_get(index)
	
	if not obj_data.has_palettes():
		material.set_shader_parameter("reindex", sprite.bit_depth == 8)
	
	var source_image := sprite.image
	
	if rects.is_empty():
		rects.append(Rect2i(0, 0, 
			source_image.get_width(),
			source_image.get_height()))
		
		offsets.append(Vector2i.ZERO)
	
	# Likely slower, but more accurate (?) representation
	for rect in rects.size():
		var new_tex: TextureRect = TextureRect.new()
		new_tex.mouse_filter = MOUSE_FILTER_IGNORE
		new_tex.position = (offsets[rect] + rects[rect].position) - Vector2i(128, 128)
		
		var empty_pixels: PackedByteArray = []
		empty_pixels.resize(rects[rect].size.x * rects[rect].size.y)
		
		var target_image := Image.create_from_data(
			rects[rect].size.x,
			rects[rect].size.y,
			false, Image.FORMAT_L8, empty_pixels
		)
		
		target_image.blit_rect(
			source_image,
			rects[rect],
			Vector2i(0,0)
		)
		
		new_tex.texture = ImageTexture.create_from_image(target_image)
		new_tex.use_parent_material = true
		add_child(new_tex)


func get_palette(index: int) -> PackedByteArray:
	# Global palette
	if obj_data.has_palettes():
		return obj_data.palette_get(palette_index).palette
	
	# Embedded palette
	var sprite: BinSprite = obj_data.sprite_get(index)
	return sprite.palette


func load_palette(index: int) -> void:
	palette_index = index
	material.set_shader_parameter("palette", get_palette(palette_index))


func reload_palette() -> void:
	if obj_data.has_palettes():
		load_palette(palette_index)
	else:
		load_palette(sprite_index)
