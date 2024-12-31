extends Button

#@export var type_dropdown: OptionButton
@export var after: bool = false

@onready var script_edit: ScriptEdit = owner


func _ready() -> void:
	pressed.connect(on_pressed)


func on_pressed() -> void:
	var id: int = script_edit.new_instruction_type
	var instruction: Instruction = ScriptInstructions.get_instruction(id)
	var at_index: int = max(0, script_edit.instruction_index + int(after))
	script_edit.script_instruction_insert(at_index, instruction)
