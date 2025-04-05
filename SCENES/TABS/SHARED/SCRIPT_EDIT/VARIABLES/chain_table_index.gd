extends SteppingSpinBox

@onready var var_edit: VariableEdit = owner


func _ready() -> void:
	max_value = var_edit.play_data.chain_tables.size() - 1
	
	if min_value == max_value:
		editable = false

	value_changed.connect(var_edit.set_chain_table)
