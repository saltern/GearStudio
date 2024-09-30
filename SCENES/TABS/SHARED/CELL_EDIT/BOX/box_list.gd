extends ItemList
var current_selection: int = -1

const STRING_BOX_TYPE_UNKNOWN: String = "Unknown"

const box_types: Dictionary = {
	0: "Hitbox",
	1: "Hitbox",
	2: "Hurtbox",
	3: "Region (Back)",
	4: "Collision Extend",
	5: "Spawn Point",
	6: "Region (Front)",
}

@onready var cell_edit: CellEdit = get_owner()
var current_cell: Cell


func _ready() -> void:
	cell_edit.cell_updated.connect(on_cell_update)
	cell_edit.box_selected_index.connect(external_select)
	cell_edit.box_deselected.connect(deselect)
	cell_edit.box_deselected_all.connect(external_clear_selection)
	cell_edit.box_editing_toggled.connect(check_enable)
	cell_edit.box_drawing_mode_changed.connect(check_enable)
	cell_edit.box_updated.connect(external_update)

	multi_selected.connect(on_multi_selected)
	empty_clicked.connect(on_empty_clicked)


func on_cell_update(cell: Cell) -> void:
	if cell == current_cell:
		update(cell.boxes, current_selection)
	else:
		update(cell.boxes)
	
	current_cell = cell


func update(boxes: Array[BoxInfo], reselect: int = -1) -> void:
	current_selection = -1
	clear()
	
	for box in boxes:
		var type: String = get_type_text(box)
		
		add_item("Box %02d, Type: %s (%s)" % [
				item_count, box.type, type])
		
		set_item_tooltip_enabled(item_count - 1, false)
	
	check_enable(cell_edit.box_edits_allowed)
	
	if reselect != -1 and reselect < item_count:
		current_selection = reselect
		select(current_selection)


func get_type_text(box_info: BoxInfo) -> String:
	var type: String = STRING_BOX_TYPE_UNKNOWN
	
	if box_info.type == 3 || box_info.type == 6:
		type = box_types[box_info.type]
		
		var offset_x: String = "%s" % (box_info.crop_x_offset)
		var offset_y: String = "%s" % (box_info.crop_y_offset)
		
		type  += " [%s, %s]" % [offset_x, offset_y]
	
	elif box_info.type in box_types:
		type = box_types[box_info.type]
	
	return type


func check_enable(_enabled: bool) -> void:
	var new_value: bool = \
		cell_edit.box_edits_allowed and !cell_edit.box_drawing_mode
	
	for item in item_count:
		set_item_disabled(item, !new_value)


func on_multi_selected(index: int, _selected: bool) -> void:
	current_selection = index
	cell_edit.box_set_selection(get_selected_items())
		

func on_empty_clicked(_ignored: Vector2, button_index: int) -> void:
	if button_index != MOUSE_BUTTON_LEFT:
		return
	
	cell_edit.box_deselect_all()


func external_select(index: int) -> void:
	select(index)
	current_selection = index


func external_clear_selection() -> void:
	deselect_all()
	current_selection = -1


func external_update(_box: BoxInfo) -> void:
	if current_cell == cell_edit.this_cell:
		update(cell_edit.this_cell.boxes, current_selection)
	else:
		update(cell_edit.this_cell.boxes)
