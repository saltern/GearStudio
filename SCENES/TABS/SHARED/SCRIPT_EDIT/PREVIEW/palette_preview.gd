extends Node2D

@onready var script_edit: ScriptEdit = owner


func _ready() -> void:
	script_edit.action_select_instruction.connect(on_instruction_selected)
	script_edit.action_loaded.connect(hide)


func on_instruction_selected(index: int) -> void:
	var instruction: Instruction = script_edit.script_instruction_get(index)
	
	if instruction.id == ScriptInstructions.ID_PALETTE:
		show()
	else:
		hide()
