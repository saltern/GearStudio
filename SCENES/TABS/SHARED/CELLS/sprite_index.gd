extends SpinBox


func _ready() -> void:
	var obj_state: ObjectEditState = SessionData.object_state_get(
		get_owner().get_parent().name)
	
	obj_state.cell_updated.connect(on_cell_update)
	
	max_value = obj_state.data.sprites.size() - 1
	value_changed.connect(SessionData.sprite_set_index)


func on_cell_update(cell: Cell) -> void:
	call_deferred("set_value_no_signal", cell.sprite_info.index)
