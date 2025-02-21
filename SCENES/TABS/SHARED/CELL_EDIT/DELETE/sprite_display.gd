extends CellSpriteDisplay

@export var cell_index: SteppingSpinBox


func _ready() -> void:
	provider = owner
	
	var cell_edit: CellEdit = owner
	cell_index.value_changed.connect(cell_selected)
	cell_edit.cell_count_changed.connect(on_cell_count_changed)
	
	if provider.obj_data.has("cells"):
		cell_selected(cell_index.value)


func cell_selected(index: int) -> void:
	load_cell(provider.obj_data.cells[index])


func on_cell_count_changed() -> void:
	cell_selected(cell_index.value)
