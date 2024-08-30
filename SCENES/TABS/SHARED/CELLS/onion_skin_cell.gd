extends SpinBox

signal update_onion_skin
signal disable_onion_skin

var obj_state: ObjectEditState


func _ready() -> void:
	obj_state = SessionData.object_state_get(get_owner().get_parent().name)
	min_value = -1
	max_value = obj_state.data.cells.size() - 1
	value = -1
	value_changed.connect(load_onion_skin)


func load_onion_skin(cell_index: int) -> void:
	if cell_index == -1:
		disable_onion_skin.emit()
	else:
		update_onion_skin.emit(obj_state.cell_get(cell_index))
