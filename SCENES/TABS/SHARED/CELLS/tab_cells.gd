extends MarginContainer

@export var cell_index: SpinBox

@export var preview_background: TextureRect

@export_group("Sprite Info")
@export var sprite_index: SpinBox
@export var sprite_offset_x: SpinBox
@export var sprite_offset_y: SpinBox

@export_group("Boxes")
@export var box_allow_edits: CheckButton
@export var box_list: ItemList
@export var box_type: SpinBox
@export var box_offset_x: SpinBox
@export var box_offset_y: SpinBox
@export var box_width: SpinBox
@export var box_height: SpinBox

@export var sprite_node: Sprite2D
@export var box_draw: Control

var data: CharacterData

var palette_shader: ShaderMaterial

var this_cell: Cell
var this_box: BoxInfo
var this_box_index: int
var block_edits: bool = false


func _ready() -> void:
	box_list.data = data
	box_draw.data = data
	
	preview_background.background_clicked.connect(deselect_box)
	
	#region Sprite Info
	sprite_index.max_value = data.sprites.size() - 1
	sprite_index.value_changed.connect(cell_change_sprite_index)
	sprite_offset_x.value_changed.connect(cell_change_sprite_offset_x)
	sprite_offset_y.value_changed.connect(cell_change_sprite_offset_y)
	#endregion
	
	#region Cells
	if data.cells.size() > 0:
		load_cell(0)
	
	cell_index.max_value = data.cells.size() - 1
	cell_index.value_changed.connect(load_cell)
	#endregion
	
	#region Palettes
	palette_shader = sprite_node.material
	if data.palettes.size() > 0:
		palette_shader.set_shader_parameter(
				"palette", data.palettes[0].palette)
	#endregion
	
	#region Boxes
	box_type.value_changed.connect(cell_change_box_type)
	box_offset_x.value_changed.connect(cell_change_box_offset_x)
	box_offset_y.value_changed.connect(cell_change_box_offset_y)
	box_width.value_changed.connect(cell_change_box_width)
	box_height.value_changed.connect(cell_change_box_height)
	#endregion


func load_cell(index: int = 0) -> void:
	data.cell_index = index
	this_cell = data.cells[index]
	
	if this_cell.sprite_info.index < data.sprites.size():
		load_cell_sprite(this_cell.sprite_info.index)
	else:
		sprite_node.texture = null
	
	load_cell_sprite_offset()
	
	box_list.update()
	for node in get_tree().get_nodes_in_group("box_editors"):
		node.set_value_no_signal(0)
	deselect_box()
	
	box_draw.load_boxes()
	
	# Ridiculous, but set_value_no_signal() seems bugged
	# Workaround to keep spinboxes from changing other cells' data when
	# you leave focus on them and change cells
	await get_tree().physics_frame
	await get_tree().physics_frame

	sprite_index.set_value_no_signal(data.cells[index].sprite_info.index)
	sprite_offset_x.set_value_no_signal(data.cells[index].sprite_info.position.x)
	sprite_offset_y.set_value_no_signal(data.cells[index].sprite_info.position.y)


#region Sprite Info
func load_cell_sprite(index: int = 0) -> void:
	sprite_node.texture = data.sprites[index].texture


func load_cell_sprite_offset() -> void:
	sprite_node.offset = this_cell.sprite_info.position


func cell_change_sprite_index(new_value: int = 0) -> void:		
	this_cell.sprite_info.index = new_value
	load_cell_sprite(this_cell.sprite_info.index)


func cell_change_sprite_offset_x(new_value: int = 0) -> void:
	if block_edits:
		return
		
	this_cell.sprite_info.position.x = new_value
	load_cell_sprite_offset()


func cell_change_sprite_offset_y(new_value: int = 0) -> void:
	if block_edits:
		return
		
	this_cell.sprite_info.position.y = new_value
	load_cell_sprite_offset()
#endregion


#region Boxes
func select_box(index: int, at_position := Vector2.ZERO, mouse_button_index: int = 0) -> void:
	if mouse_button_index != MOUSE_BUTTON_LEFT:
		return
	
	if this_cell.boxes[index] == this_box:
		deselect_box(Vector2.ZERO, 0)
		box_draw.get_child(index).external_select(false)
		return
	
	deselect_box()
	box_draw.get_child(index).external_select(true)
	this_box = this_cell.boxes[index]
	this_box_index = index
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	box_type.set_value_no_signal(this_box.type)
	box_offset_x.set_value_no_signal(this_box.rect.position.x)
	box_offset_y.set_value_no_signal(this_box.rect.position.y)
	box_width.set_value_no_signal(this_box.rect.size.x)
	box_height.set_value_no_signal(this_box.rect.size.y)
	
	if not box_allow_edits.button_pressed:
		return
	
	for node in get_tree().get_nodes_in_group("box_editors"):
		node.editable = true


func deselect_box(_pos: Vector2 = Vector2.ZERO, _mouse_button: int = 0) -> void:
	this_box = BoxInfo.new()
	
	for node in get_tree().get_nodes_in_group("box_editors"):
		node.set_value_no_signal(0)
	
	box_list.deselect_all()
	
	for box in box_draw.get_child_count():
		box_draw.get_child(box).external_select(false)


func cell_change_box_type(new_value: int = 0) -> void:
	this_box.type = new_value
	box_draw.box_update(this_box_index)


func cell_change_box_offset_x(new_value: int = 0) -> void:
	this_box.rect.position.x = new_value
	box_draw.box_update(this_box_index)


func cell_change_box_offset_y(new_value: int = 0) -> void:
	this_box.rect.position.y = new_value
	box_draw.box_update(this_box_index)


func cell_change_box_width(new_value: int = 0) -> void:
	this_box.rect.size.x = new_value
	box_draw.box_update(this_box_index)


func cell_change_box_height(new_value: int = 0) -> void:
	this_box.rect.size.y = new_value
	box_draw.box_update(this_box_index)
#endregion
