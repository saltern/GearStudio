extends SteppingSpinBox

@export var cell_to: SteppingSpinBox

var obj_data: Dictionary

@onready var cell_edit: CellEdit = owner


func _ready() -> void:
	obj_data = cell_edit.obj_data
	cell_edit.cell_updated.connect(on_external_selection.unbind(1))
	cell_edit.cell_count_changed.connect(update)
	cell_to.value_changed.connect(update.unbind(1))
	update()


func update() -> void:
	value = min(value, cell_to.value)
	max_value = obj_data["cells"].size()


func on_external_selection() -> void:
	value = cell_edit.cell_index
