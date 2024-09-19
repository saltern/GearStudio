extends SpinBox

signal update_onion_skin
signal disable_onion_skin

@onready var cell_edit: CellEdit = get_owner()


func _ready() -> void:
	min_value = -1
	max_value = cell_edit.cell_get_count() - 1
	value = -1
	value_changed.connect(load_onion_skin)


func load_onion_skin(cell_index: int) -> void:
	if cell_index == -1:
		disable_onion_skin.emit()
	else:
		update_onion_skin.emit(cell_edit.cell_get(cell_index))
