extends SpinBox


func _ready() -> void:
	var obj_state: ObjectEditState = SessionData.object_state_get(
		get_owner().get_parent().name)
	
	value_changed.connect(obj_state.cell_load)

	max_value = obj_state.data.cells.size() - 1
