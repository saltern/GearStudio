extends SteppingSpinBox

@export var cell_from: SteppingSpinBox

var obj_data: Dictionary

@onready var cell_edit: CellEdit = owner


func _ready() -> void:
	obj_data = cell_edit.obj_data
	cell_edit.cell_count_changed.connect(update)
	cell_from.value_changed.connect(update.unbind(1))
	update()


func update() -> void:
	#min_value = cell_from.value
	value = max(value, cell_from.value)
	max_value = obj_data["cells"].size()
