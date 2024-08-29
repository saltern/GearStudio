extends SpinBox


func _ready() -> void:
	value_changed.connect(SessionData.sprite_set_position_x)
	
	var obj_state: ObjectEditState = SessionData.object_state_get(
		get_owner().get_parent().name)
	
	obj_state.cell_updated.connect(on_cell_update)


func on_cell_update(cell: Cell) -> void:
	call_deferred("set_value_no_signal", cell.sprite_info.position.x)
