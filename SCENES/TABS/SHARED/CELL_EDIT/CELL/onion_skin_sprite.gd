extends Sprite2D

@export var front_toggle: CheckButton

@onready var cell_edit: CellEdit = get_owner()


func _ready() -> void:
	Settings.onion_color_changed.connect(update_color)
	front_toggle.toggled.connect(on_toggle_front)
	material = material.duplicate()
	update_color()


func update_color() -> void:
	var new_color: Color = Settings.cell_onion_skin
	
	var onion_colors: PackedInt32Array = []
	
	for transp in 4:
		onion_colors.append(0x00)
		
	for index in range(1, 256):
		onion_colors.append(new_color.r8)
		onion_colors.append(new_color.g8)
		onion_colors.append(new_color.b8)
		onion_colors.append(new_color.a8)
	
	material.set_shader_parameter("palette", PackedInt32Array(onion_colors))


func on_onion_skin_update(cell: Cell) -> void:
	if cell.sprite_info.index < cell_edit.sprite_get_count():
		load_cell_sprite(cell.sprite_info.index, cell.boxes)
	
	else:
		texture = null
		
	offset = cell.sprite_info.position


func on_onion_skin_disable() -> void:
	texture = null


func on_toggle_front(toggled_on: bool) -> void:
	if toggled_on:
		z_index = 1
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
