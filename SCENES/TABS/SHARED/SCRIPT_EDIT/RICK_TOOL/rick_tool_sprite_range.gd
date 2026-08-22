extends SteppingSpinBox

@onready var script_edit: ScriptEdit = owner


func _ready() -> void:
	visibility_changed.connect(update_max_value)
	update_max_value()


func update_max_value() -> void:
	max_value = script_edit.obj_data.get_cell_count() - 1
