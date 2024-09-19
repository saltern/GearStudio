extends SpinBox

@onready var cell_edit: CellEdit = get_owner()


func _ready() -> void:
	cell_edit.cell_updated.connect(on_cell_update)
	value_changed.connect(cell_edit.sprite_set_index)
	
	max_value = cell_edit.sprite_get_count() - 1


func on_cell_update(cell: Cell) -> void:
	call_deferred("set_value_no_signal", cell.sprite_info.index)
