extends Sprite2D

var obj_state: ObjectEditState
var pal_state: PaletteEditState


func _enter_tree() -> void:
	if get_owner().get_parent().name != "player":
		material = material.duplicate()


func _ready() -> void:
	obj_state = SessionData.object_state_get(
		get_owner().get_parent().name)
	pal_state = SessionData.palette_state_get(
		get_owner().get_parent().get_parent().get_index())
	
	obj_state.cell_updated.connect(on_cell_update)
	obj_state.box_updated.connect(on_box_update)
	
	pal_state.changed_palette.connect(pal_state_palette_changed)


func on_cell_update(cell: Cell) -> void:
	if cell.sprite_info.index < obj_state.sprite_get_count():
		load_cell_sprite(cell.sprite_info.index, cell.boxes)
	
	else:
		texture = null
		
	offset = cell.sprite_info.position


func on_box_update(_box: BoxInfo) -> void:
	on_cell_update(SessionData.cell_get_this())


func pal_state_palette_changed() -> void:
	material.set_shader_parameter(
		"palette", get_sprite_palette(obj_state.sprite_get_index()))


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


func get_sprite_palette(index: int) -> PackedByteArray:
	var sprite: BinSprite = obj_state.sprite_get(index)
	
	# No embedded pal
	if sprite.palette.is_empty():
		return pal_state.this_palette.palette
	
	# Embedded pal
	var palette: PackedByteArray = sprite.palette
	
	@warning_ignore("integer_division")
	for color_index in range(0, palette.size() / 4):
		var new_alpha: int = palette[4 * color_index + 3]
		new_alpha = min(0xFF, new_alpha * 2)
		palette[4 * color_index + 3] = new_alpha
	
	return palette
