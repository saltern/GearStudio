extends ItemList

var current_cell: Cell
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
	obj_state.box_selected_index.connect(select)
	obj_state.box_deselected.connect(deselect)
	obj_state.box_deselected_all.connect(external_clear_selection)
	obj_state.box_editing_toggled.connect(check_enable)
	obj_state.box_drawing_mode_changed.connect(check_enable)
	obj_state.box_updated.connect(external_update)

	multi_selected.connect(on_multi_selected)
	empty_clicked.connect(on_empty_clicked)


func on_cell_update(cell: Cell) -> void:
	current_cell = cell
	update(current_cell.boxes)


func update(boxes: Array[BoxInfo]) -> void:
	current_selection = -1
	clear()
	
	for box in boxes:
		var type: String = get_type_text(box)
		
		add_item("Box %02d, Type: %s (%s)" % [
				item_count, box.type, type])
		
		set_item_tooltip_enabled(item_count - 1, false)
	
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


func check_enable(_enabled: bool) -> void:
	var new_value: bool = \
		SessionData.box_get_edits_allowed() and !SessionData.box_get_draw_mode()
	
	for item in item_count:
		set_item_disabled(item, !new_value)


func on_multi_selected(index: int, selected: bool) -> void:
	SessionData.box_set_selection(get_selected_items())
		

func on_empty_clicked(_ignored: Vector2, button_index: int) -> void:
	if button_index != MOUSE_BUTTON_LEFT:
		return
	
	SessionData.box_deselect_all()


func external_clear_selection() -> void:
	deselect_all()
	current_selection = -1


func external_update(_box: BoxInfo) -> void:
	#var old_selection: int = -1
	
	#if get_selected_items().size() > 0:
		#old_selection = get_selected_items()[0]
	
	update(SessionData.cell_get_this().boxes)
	
	#if old_selection != -1:
		#select(old_selection)
