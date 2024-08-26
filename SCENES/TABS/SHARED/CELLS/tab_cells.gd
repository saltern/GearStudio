extends MarginContainer

@export var cell_index: SpinBox

@export var preview_background: TextureRect

@export_group("Sprite Info")
@export var sprite_index: SpinBox
@export var sprite_offset_x: SpinBox
@export var sprite_offset_y: SpinBox

@export_group("Boxes")
@export var box_allow_edits: CheckButton
@export var box_display_regions: CheckButton
@export var box_list: ItemList
@export var box_type: SpinBox
@export var box_offset_x: SpinBox
@export var box_offset_y: SpinBox
@export var box_width: SpinBox
@export var box_height: SpinBox

@export var sprite_node: Sprite2D
@export var box_draw: Control

var palette_shader: ShaderMaterial

var block_edits: bool = false

@onready var obj_state: ObjectEditState = SessionData.get_object_state(
	get_parent().name)

@onready var pal_state: PaletteEditState = SessionData.get_palette_state(
	get_parent().get_parent().get_index())


func _ready() -> void:
	box_draw.obj_state = obj_state
	
	obj_state.selected_box.connect(select_box)
	obj_state.deselected_boxes.connect(deselect_boxes)
	
	#region Sprite Info
	sprite_index.max_value = obj_state.data.sprites.size() - 1
	sprite_index.value_changed.connect(cell_change_sprite_index)
	sprite_offset_x.value_changed.connect(cell_change_sprite_offset_x)
	sprite_offset_y.value_changed.connect(cell_change_sprite_offset_y)
	#endregion
	
	#region Palettes
	pal_state.changed_palette.connect(pal_state_palette_changed)
	palette_shader = sprite_node.material
	#endregion
	
	#region Cells
	if obj_state.data.cells.size() > 0:
		load_cell(0)
	
	cell_index.max_value = obj_state.data.cells.size() - 1
	cell_index.value_changed.connect(load_cell)
	#endregion
	
	#region Boxes
	box_draw.obj_state = obj_state
	
	box_allow_edits.toggled.connect(box_toggle_editing)
	box_display_regions.toggled.connect(box_toggle_regions)
	
	obj_state.selected_box.connect(box_list.external_selection)
	obj_state.deselected_boxes.connect(box_list.external_clear_selection)
	obj_state.box_editing_toggled.connect(box_list.check_enable)
	
	box_list.item_selected.connect(obj_state.select_box)
	box_list.empty_clicked.connect(obj_state.box_list_empty_clicked)
	
	box_type.value_changed.connect(cell_change_box_type)
	box_offset_x.value_changed.connect(cell_change_box_offset_x)
	box_offset_y.value_changed.connect(cell_change_box_offset_y)
	box_width.value_changed.connect(cell_change_box_width)
	box_height.value_changed.connect(cell_change_box_height)
	
	box_toggle_editing(false)
	#endregion


func load_cell(index: int = 0) -> void:
	var cell: Cell = obj_state.get_cell(index)
	
	# Load boxes first as they may contain sheet information
	box_list.update(cell.boxes)
	box_list.check_enable(obj_state.box_edits_allowed)
	for node in get_tree().get_nodes_in_group("box_editors"):
		node.set_value_no_signal(0)
	deselect_boxes()
	
	box_draw.load_boxes(cell.boxes)
	
	if cell.sprite_info.index < obj_state.data.sprites.size():
		load_cell_sprite(cell.sprite_info.index, cell.boxes)
	else:
		sprite_node.texture = null
	
	load_cell_sprite_offset()
	
	# Ridiculous, but set_value_no_signal() seems bugged
	# Workaround to keep spinboxes from changing other cells' data when
	# you leave focus on them and change cells
	await get_tree().physics_frame
	await get_tree().physics_frame

	sprite_index.set_value_no_signal(cell.sprite_info.index)
	sprite_offset_x.set_value_no_signal(cell.sprite_info.position.x)
	sprite_offset_y.set_value_no_signal(cell.sprite_info.position.y)


#region Sprite Info
func load_cell_sprite(index: int, boxes: Array[BoxInfo]) -> void:
	var cutout_list: Array[Rect2i]
	var offset_list: Array[Vector2i]
	
	for box in boxes:
		if box.type & 0xFFFF != 3:
			continue
		
		var offset_x: int = 8 * ((box.type >> 16) & 0xFF)
		var offset_y: int = 8 * ((box.type >> 24) & 0xFF)
		offset_list.append(Vector2i(offset_x, offset_y))
		cutout_list.append(box.rect)
	
	if cutout_list.size() == 0:
		load_cell_sprite_whole(index)
	
	else:
		load_cell_sprite_pieces(index, cutout_list, offset_list)
	
	palette_shader.set_shader_parameter(
			"palette", get_sprite_palette(index))
	

func load_cell_sprite_whole(index: int) -> void:
	sprite_node.texture = obj_state.data.sprites[index].texture


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
	
	sprite_node.texture = new_texture


func pal_state_palette_changed() -> void:
	palette_shader.set_shader_parameter(
		"palette", get_sprite_palette(obj_state.this_cell.sprite_info.index)
	)


func get_sprite_palette(index: int) -> PackedByteArray:
	var sprite: BinSprite = obj_state.data.sprites[index]
	
	# No embedded pal
	if sprite.palette.is_empty():
		return pal_state.this_palette.palette
	
	# Embedded pal
	var palette: PackedByteArray = sprite.palette
	
	for color_index in range(0, palette.size() / 4):
		var new_alpha: int = palette[4 * color_index + 3]
		new_alpha = min(0xFF, new_alpha * 2)
		palette[4 * color_index + 3] = new_alpha
	
	return palette


func load_cell_sprite_offset() -> void:
	sprite_node.offset = obj_state.this_cell.sprite_info.position


func cell_change_sprite_index(new_value: int = 0) -> void:		
	obj_state.this_cell.sprite_info.index = new_value
	load_cell_sprite(new_value, obj_state.this_cell.boxes)


func cell_change_sprite_offset_x(new_value: int = 0) -> void:
	if block_edits:
		return
		
	obj_state.this_cell.sprite_info.position.x = new_value
	load_cell_sprite_offset()


func cell_change_sprite_offset_y(new_value: int = 0) -> void:
	if block_edits:
		return
		
	obj_state.this_cell.sprite_info.position.y = new_value
	load_cell_sprite_offset()
#endregion


#region Boxes
func select_box(index: int) -> void:
	if obj_state.this_cell.boxes[index] == obj_state.this_box:
		deselect_boxes()
		box_draw.get_child(index).external_select(false)
		return
	
	deselect_boxes()
	box_draw.get_child(index).external_select(true)
	obj_state.this_box = obj_state.this_cell.boxes[index]
	obj_state.box_index = index
	
	# Apparently not necessary here?
	#await get_tree().physics_frame
	#await get_tree().physics_frame
	
	box_type.set_value_no_signal(obj_state.this_box.type)
	box_offset_x.set_value_no_signal(obj_state.this_box.rect.position.x)
	box_offset_y.set_value_no_signal(obj_state.this_box.rect.position.y)
	box_width.set_value_no_signal(obj_state.this_box.rect.size.x)
	box_height.set_value_no_signal(obj_state.this_box.rect.size.y)
	
	if not box_allow_edits.button_pressed:
		return
	
	for node in get_tree().get_nodes_in_group("box_editors"):
		node.editable = true


func deselect_boxes() -> void:
	obj_state.this_box = BoxInfo.new()
	
	for node in get_tree().get_nodes_in_group("box_editors"):
		node.set_value_no_signal(0)
	
	#box_list.deselect_all()
	
	for box in box_draw.get_child_count():
		box_draw.get_child(box).external_select(false)


func cell_change_box_type(new_value: int = 0) -> void:
	obj_state.this_box.type = new_value
	box_draw.box_update(obj_state.box_index, obj_state.this_box)


func cell_change_box_offset_x(new_value: int = 0) -> void:
	obj_state.this_box.rect.position.x = new_value
	box_draw.box_update(obj_state.box_index, obj_state.this_box)


func cell_change_box_offset_y(new_value: int = 0) -> void:
	obj_state.this_box.rect.position.y = new_value
	box_draw.box_update(obj_state.box_index, obj_state.this_box)


func cell_change_box_width(new_value: int = 0) -> void:
	obj_state.this_box.rect.size.x = new_value
	box_draw.box_update(obj_state.box_index, obj_state.this_box)


func cell_change_box_height(new_value: int = 0) -> void:
	obj_state.this_box.rect.size.y = new_value
	box_draw.box_update(obj_state.box_index, obj_state.this_box)
#endregion


func preview_background_clicked() -> void:
	obj_state.deselect_boxes()


func on_box_changed(index: int, rect: Rect2i) -> void:
	obj_state.data.cells[obj_state.cell_index].boxes[index].rect = rect
	
	box_offset_x.set_value_no_signal(rect.position.x)
	box_offset_y.set_value_no_signal(rect.position.y)
	box_width.set_value_no_signal(rect.size.x)
	box_height.set_value_no_signal(rect.size.y)


func box_toggle_editing(new_value: bool) -> void:
	for node in get_tree().get_nodes_in_group("box_editors"):
		node.editable = new_value
	
	obj_state.set_box_editing(new_value)


func box_toggle_regions(new_value: bool) -> void:
	obj_state.set_box_regions(new_value)
