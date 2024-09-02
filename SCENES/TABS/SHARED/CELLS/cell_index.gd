extends SpinBox

var obj_state: ObjectEditState


func _ready() -> void:
	obj_state = SessionData.object_state_get(get_owner().get_parent().name)
	
	value_changed.connect(obj_state.cell_load)
	obj_state.cell_updated.connect(update)
	
	max_value = obj_state.data.cells.size() - 1


func update(cell: Cell) -> void:
	call_deferred("set_value_no_signal", obj_state.cell_index)
