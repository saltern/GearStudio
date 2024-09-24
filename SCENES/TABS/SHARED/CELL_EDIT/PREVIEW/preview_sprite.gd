extends Control

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
		unload_sprite()
		
	position = cell.sprite_info.position


func on_box_update(_box: BoxInfo) -> void:
	on_cell_update(cell_edit.this_cell)


func pal_state_palette_changed(_palette_number: int) -> void:
	material.set_shader_parameter(
		"palette", get_sprite_palette(cell_edit.sprite_get_index()))


func unload_sprite() -> void:
	for child in get_children():
		child.queue_free()


func load_cell_sprite(index: int, boxes: Array[BoxInfo]) -> void:
	unload_sprite()
	
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
		load_cell_sprite_pieces(index, [], [])
	
	else:
		load_cell_sprite_pieces(index, cutout_list, offset_list)
	
	material.set_shader_parameter("palette", get_sprite_palette(index))


func load_cell_sprite_pieces(
	index: int, rects: Array[Rect2i], offsets: Array[Vector2i]
) -> void:
	var source_image := cell_edit.sprite_get(index).image
	
	if rects.is_empty():
		rects.append(Rect2i(0, 0, 
			source_image.get_width(),
			source_image.get_height()))
		
		offsets.append(Vector2i.ZERO)
	
	# Likely slower, but more accurate (?) representation
	for rect in rects.size():
		var new_tex: TextureRect = TextureRect.new()
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
