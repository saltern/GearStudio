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

@onready var obj_state: ObjectEditState = SessionData.object_state_get(
	get_parent().name)

@onready var pal_state: PaletteEditState = SessionData.palette_state_get(
	get_parent().get_parent().get_index())


func _ready() -> void:
	#region Focus bug workaround
	cell_index.get_line_edit().focus_mode = Control.FOCUS_NONE
	#endregion
	
	obj_state.cell_updated.connect(cell_load)
	obj_state.box_selected.connect(box_select)
	obj_state.boxes_deselected.connect(box_editors_clear)
	
	#region Palettes
	pal_state.changed_palette.connect(pal_state_palette_changed)
	palette_shader = sprite_node.material
	#endregion
	
	#region Cells
	if obj_state.data.cells.size() > 0:
		cell_load(0)
	
	cell_index.max_value = obj_state.data.cells.size() - 1
	cell_index.value_changed.connect(cell_load)
	#endregion
	
	#region Boxes
	box_allow_edits.toggled.connect(SessionData.box_set_editing)
	box_display_regions.toggled.connect(SessionData.box_set_display_regions)	
	box_toggle_editing(false)
	#endregion


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
		
	if not event is InputEventKey:
		return
		
	if not event.pressed or event.echo:
		return
	
	if Input.is_action_just_pressed("undo"):
		SessionData.undo()
	
	elif Input.is_action_just_pressed("redo"):
		SessionData.redo()


func cell_load(index: int = 0) -> void:
	obj_state.cell_load(index)
	var cell: Cell = obj_state.cell_get(index)
	
	# Load boxes first as they may contain sheet information
	box_list.update(cell.boxes)
	
	for node in get_tree().get_nodes_in_group("box_editors"):
		node.set_value_no_signal(0)
	
	SessionData.box_deselect_all()
	
	box_draw.load_boxes(cell.boxes)
	
	if cell.sprite_info.index < obj_state.sprite_get_count():
		load_cell_sprite(cell.sprite_info.index, cell.boxes)
	else:
		sprite_node.texture = null
	
	load_cell_sprite_offset()
	
	cell_index.set_value_no_signal(SessionData.cell_get_index())
	sprite_index.set_value_no_signal(cell.sprite_info.index)
	sprite_offset_x.set_value_no_signal(cell.sprite_info.position.x)
	sprite_offset_y.set_value_no_signal(cell.sprite_info.position.y)


#region Sprite Info
func reload_sprite() -> void:
	var cell: Cell = obj_state.this_cell
	load_cell_sprite(cell.sprite_info.index, cell.boxes)


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
		"palette", get_sprite_palette(obj_state.sprite_get_index())
	)


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


func load_cell_sprite_offset() -> void:
	sprite_node.offset = obj_state.sprite_get_position()
#endregion


#region Boxes
func box_select(_index: int) -> void:	
	box_editors_update(SessionData.box_get_this())
	
	if not box_allow_edits.button_pressed:
		return
	
	for node in get_tree().get_nodes_in_group("box_editors"):
		node.editable = true


func box_editors_clear() -> void:	
	for node in get_tree().get_nodes_in_group("box_editors"):
		node.set_value_no_signal(0)


func box_editors_update(box_info: BoxInfo) -> void:
	box_type.set_value_no_signal(box_info.type)
	box_offset_x.set_value_no_signal(box_info.rect.position.x)
	box_offset_y.set_value_no_signal(box_info.rect.position.y)
	box_width.set_value_no_signal(box_info.rect.size.x)
	box_height.set_value_no_signal(box_info.rect.size.y)
#endregion


func preview_background_clicked() -> void:
	SessionData.box_deselect_all()


func on_box_changed(index: int, rect: Rect2i) -> void:
	SessionData.box_set_rect_for(index, rect)
	
	box_offset_x.set_value_no_signal(rect.position.x)
	box_offset_y.set_value_no_signal(rect.position.y)
	box_width.set_value_no_signal(rect.size.x)
	box_height.set_value_no_signal(rect.size.y)


func box_toggle_editing(new_value: bool) -> void:
	for node in get_tree().get_nodes_in_group("box_editors"):
		node.editable = new_value
	
	SessionData.box_set_editing(new_value)


func box_toggle_regions(new_value: bool) -> void:
	SessionData.box_set_display_regions(new_value)
