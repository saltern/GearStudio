extends CellSpriteDisplay

@export var cell_index: SteppingSpinBox


func _ready() -> void:
	var cell_edit: CellEdit = owner
	obj_data = cell_edit.obj_data
	
	cell_index.value_changed.connect(cell_index_changed)
	cell_index_changed(cell_index.value)


func cell_index_changed(index: int) -> void:
	load_cell(obj_data.cells[index])
