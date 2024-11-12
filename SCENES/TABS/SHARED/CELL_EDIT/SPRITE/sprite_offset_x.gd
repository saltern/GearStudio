extends SteppingSpinBox

@onready var cell_edit: CellEdit = get_owner()


func _ready() -> void:
	value_changed.connect(cell_edit.sprite_set_position_x)
	cell_edit.cell_updated.connect(on_cell_update)


func on_cell_update(cell: Cell) -> void:
	call_deferred("set_value_no_signal", cell.sprite_x_offset)
