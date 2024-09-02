extends ItemList

var current_selection: int = -1

const box_types: Dictionary = {
	1: "Hitbox",
	2: "Hurtbox",
	3: "Region",
	5: "Effect Spawn Point",
	6: "Region",
}


func _ready() -> void:
	var obj_state = SessionData.object_state_get(
		get_owner().get_parent().name)
	
	obj_state.cell_updated.connect(on_cell_update)
	obj_state.box_selected_index.connect(external_selection)
	obj_state.boxes_deselected.connect(external_clear_selection)
	obj_state.box_editing_toggled.connect(check_enable)
	obj_state.box_updated.connect(external_update)
	
	item_selected.connect(on_item_selected)
	empty_clicked.connect(on_empty_clicked)


func on_cell_update(cell: Cell) -> void:
	update(cell.boxes)


func update(boxes: Array[BoxInfo]) -> void:
	current_selection = -1
	clear()
	
	for box in boxes:
		var type: String = get_type_text(box)
		
		add_item("Box %02d, Type: %s (%s)" % [
				item_count, box.type, type])
	
	check_enable(SessionData.box_get_edits_allowed())


func get_type_text(box_info: BoxInfo) -> String:
	var type: String = "Unknown"
	
	if box_info.type == 3 || box_info.type == 6:
		type = box_types[box_info.type]
		
		var offset_x: String = "%s" % (8 * box_info.crop_x_offset)
		var offset_y: String = "%s" % (8 * box_info.crop_y_offset)
		
		type  += " (%s, %s)" % [offset_x, offset_y]
	
	elif box_info.type in box_types:
		type = box_types[box_info.type]
	
	return type


func check_enable(enabled: bool) -> void:
	for item in item_count:
		set_item_disabled(item, !enabled)


func on_item_selected(index: int) -> void:
	if current_selection == index:
		current_selection = -1
		SessionData.box_deselect_all()
	
	else:
		current_selection = index
		SessionData.box_select(index)
		

func on_empty_clicked(_ignored: Vector2, button_index: int) -> void:
	if button_index != MOUSE_BUTTON_LEFT:
		return
	
	SessionData.box_deselect_all()


func external_selection(index: int) -> void:
	select(index)


func external_clear_selection() -> void:
	deselect_all()
	current_selection = -1


func external_update(_box: BoxInfo) -> void:
	var old_selection: int = -1
	
	if get_selected_items().size() > 0:
		old_selection = get_selected_items()[0]
	
	update(SessionData.cell_get_this().boxes)
	
	if old_selection != -1:
		select(old_selection)
