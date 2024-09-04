extends SpinBox


func _ready() -> void:
	value_changed.connect(SessionData.box_set_crop_offset_x)

	var obj_state: ObjectEditState = SessionData.object_state_get(
			get_owner().get_parent().name)
	
	obj_state.box_editing_toggled.connect(on_editing_toggled)
	obj_state.cell_updated.connect(on_cell_update)
	obj_state.box_updated.connect(on_box_update)
	obj_state.box_selected.connect(on_box_update)
	obj_state.boxes_deselected.connect(reset)


func reset() -> void:
	call_deferred("set_value_no_signal", 0)


func on_cell_update(_cell: Cell) -> void:
	reset()


func on_box_update(box: BoxInfo) -> void:
	call_deferred("set_value_no_signal", box.crop_x_offset)


func on_editing_toggled(enabled: bool) -> void:
	editable = enabled
