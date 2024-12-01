extends Control

@export var onion_index: SpinBox
@export var front_toggle: CheckButton
@onready var cell_edit: CellEdit = get_owner()

var cell_index: int = -1


func _ready() -> void:
	Settings.onion_color_changed.connect(update_color)
	
	cell_edit.cell_updated.connect(check_update.unbind(1))
	cell_edit.box_updated.connect(check_update.unbind(1))
	
	front_toggle.toggled.connect(on_toggle_front)
	onion_index.value_changed.connect(select_onion_skin)
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


func on_toggle_front(toggled_on: bool) -> void:
	if toggled_on:
		z_index = 1
	else:
		z_index = 0


func check_update() -> void:
	if cell_edit.cell_index == cell_index:
		select_onion_skin(cell_index)


func select_onion_skin(index: int) -> void:
	cell_index = index
	
	if cell_index < 0:
		unload_sprite()
	else:
		var cell: Cell = cell_edit.cell_get(cell_index)
		load_cell_sprite(cell.sprite_index, cell.boxes)
		position = Vector2i(cell.sprite_x_offset, cell.sprite_y_offset)


func unload_sprite() -> void:
	for child in get_children():
		child.queue_free()


func load_cell_sprite(index: int, boxes: Array[BoxInfo]) -> void:
	unload_sprite()
	
	var cutout_list: Array[Rect2i]
	var offset_list: Array[Vector2i]
	
	for box in boxes:
		if box.box_type & 0xFFFF != 3 && box.box_type & 0xFFFF != 6:
			continue
		
		var offset_x: int = 8 * box.crop_x_offset
		var offset_y: int = 8 * box.crop_y_offset
		offset_list.append(Vector2i(offset_x, offset_y))
		cutout_list.append(Rect2i(
			box.x_offset, box.y_offset, box.width, box.height))
	
	load_cell_sprite_pieces(index, cutout_list, offset_list)


func load_cell_sprite_pieces(
	index: int, rects: Array[Rect2i], offsets: Array[Vector2i]
) -> void:
	var sprite: BinSprite = cell_edit.sprite_get(index)
	
	if not cell_edit.obj_data.has("palettes"):
		material.set_shader_parameter("reindex", sprite.bit_depth == 8)
	
	var source_image := sprite.image
	
	if rects.is_empty():
		rects.append(Rect2i(0, 0, 
			source_image.get_width(),
			source_image.get_height()))
		
		offsets.append(Vector2i.ZERO)
	
	# Likely slower, but more accurate (?) representation
	for rect in rects.size():
		if rects[rect].size.x < 1 or rects[rect].size.y < 1:
			continue
		
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
