extends Button

@export var from_cell_spinbox: SteppingSpinBox
@export var to_cell_spinbox: SteppingSpinBox
@export var duration_spinbox: SteppingSpinBox

@onready var script_edit: ScriptEdit = owner


func _pressed() -> void:
	var from: int = from_cell_spinbox.value
	var to: int = to_cell_spinbox.value
	var duration: int = duration_spinbox.value
	
	var this_action: Action = script_edit.this_action
	var inst_index: int = script_edit.instruction_index
	
	var counter: int = 1
	
	for i: int in range(from, to, 1):
		# Get CellBegin
		var new_cellbegin: Instruction = ScriptInstructions.get_instruction(0x00)
		
		new_cellbegin.arguments[0].value = duration
		new_cellbegin.arguments[1].value = i
		
		this_action.instructions.insert(inst_index + counter, new_cellbegin)
		counter += 1
