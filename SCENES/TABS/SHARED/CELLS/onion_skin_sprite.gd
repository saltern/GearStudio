extends Sprite2D

var obj_state: ObjectEditState


func _ready() -> void:
	obj_state = SessionData.object_state_get(
			get_owner().get_parent().name)
	
	material = material.duplicate()
	
	var onion_colors: PackedInt32Array = []
	
	for transp in 4:
		onion_colors.append(0x00)
		
	for index in 255:
		onion_colors.append(0xFF)
		onion_colors.append(0x00)
		onion_colors.append(0x00)
		onion_colors.append(0xA0)
	
	material.set_shader_parameter("palette", PackedInt32Array(onion_colors))


func on_onion_skin_update(cell: Cell) -> void:
	if cell.sprite_info.index < obj_state.sprite_get_count():
		load_cell_sprite(cell.sprite_info.index, cell.boxes)
	
	else:
		texture = null
		
	offset = cell.sprite_info.position


func on_onion_skin_disable() -> void:
	texture = null


func on_toggle_front(toggled_on: bool) -> void:
	if toggled_on:
		z_index = 2
	else:
		z_index = 0


func load_cell_sprite(index: int, boxes: Array[BoxInfo]) -> void:
	var cutout_list: Array[Rect2i]
	var offset_list: Array[Vector2i]
	
	for box in boxes:
		if box.type & 0xFFFF != 3 && box.type & 0xFFFF != 6:
			continue
		
		var offset_x: int = 8 * box.crop_x_offset
		var offset_y: int = 8 * box.crop_y_offset
		offset_list.append(Vector2i(offset_x, offset_y))
		cutout_list.append(box.rect)
	
	if cutout_list.size() == 0:
		load_cell_sprite_whole(index)
	
	else:
		load_cell_sprite_pieces(index, cutout_list, offset_list)


func load_cell_sprite_whole(index: int) -> void:
	texture = obj_state.data.sprites[index].texture


func load_cell_sprite_pieces(
	index: int,
	rects: Array[Rect2i],
	offsets: Array[Vector2i]
) -> void:
	
	var source_image := obj_state.data.sprites[index].texture.get_image()
	
	var empty_pixels: PackedByteArray = []
	empty_pixels.resize(source_image.get_data_size() * 4)
	
	var target_image := Image.create_from_data(
		source_image.get_width() * 2,
		source_image.get_height() * 2,
		false, Image.FORMAT_L8, empty_pixels
	)
	
	for rect in rects.size():
		target_image.blit_rect(
			source_image,
			# Cut from this location
			rects[rect],
			# To this location
			offsets[rect] + rects[rect].position
		)
	
	var new_texture := ImageTexture.create_from_image(target_image)
	
	texture = new_texture
