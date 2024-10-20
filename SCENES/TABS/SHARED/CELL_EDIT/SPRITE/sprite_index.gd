extends SteppingSpinBox

@onready var cell_edit: CellEdit = get_owner()


func _ready() -> void:
	cell_edit.cell_updated.connect(on_cell_update)
	value_changed.connect(cell_edit.sprite_set_index)
	
	SpriteImport.sprite_placement_finished.connect(update_max_value)
	update_max_value()


func on_cell_update(cell: Cell) -> void:
	call_deferred("set_value_no_signal", cell.sprite_info.index)


func update_max_value() -> void:
	max_value = cell_edit.sprite_get_count() - 1
