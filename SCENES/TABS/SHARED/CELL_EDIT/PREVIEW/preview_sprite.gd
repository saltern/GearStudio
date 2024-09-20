extends Sprite2D

@onready var cell_edit: CellEdit = get_owner()


func _enter_tree() -> void:
	if get_owner().get_parent().name != "player":
		material = material.duplicate()


func _ready() -> void:
	cell_edit.cell_updated.connect(on_cell_update)
	cell_edit.box_updated.connect(on_box_update)


func on_cell_update(cell: Cell) -> void:
	if cell.sprite_info.index < cell_edit.sprite_get_count():
		load_cell_sprite(cell.sprite_info.index, cell.boxes)
	
	else:
		texture = null
		
	offset = cell.sprite_info.position


func on_box_update(_box: BoxInfo) -> void:
	on_cell_update(cell_edit.this_cell)


func pal_state_palette_changed(_palette_number: int) -> void:
	material.set_shader_parameter(
		"palette", get_sprite_palette(cell_edit.sprite_get_index()))


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
	
	material.set_shader_parameter("palette", get_sprite_palette(index))


func load_cell_sprite_whole(index: int) -> void:
	texture = cell_edit.sprite_get(index).texture


func load_cell_sprite_pieces(
	index: int,
	rects: Array[Rect2i],
	offsets: Array[Vector2i]
) -> void:
	
	var source_image := cell_edit.sprite_get(index).image
	
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


func get_sprite_palette(index: int) -> PackedByteArray:
	var sprite: BinSprite = cell_edit.sprite_get(index)
	
	# No embedded pal
	if sprite.palette.is_empty() or get_owner().get_parent().name == "player":
		return cell_edit.this_palette.palette
	
	# Embedded pal
	var palette: PackedByteArray = sprite.palette
	
	@warning_ignore("integer_division")
	for color_index in range(0, palette.size() / 4):
		var new_alpha: int = palette[4 * color_index + 3]
		new_alpha = min(0xFF, new_alpha * 2)
		palette[4 * color_index + 3] = new_alpha
	
	return palette