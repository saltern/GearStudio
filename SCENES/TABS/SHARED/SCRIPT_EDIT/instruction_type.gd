extends OptionButton


func _ready() -> void:
	get_popup().wrap_controls = true
	
	for id: int in ScriptInstructions.INSTRUCTION_DB:
		var instruction: Instruction = ScriptInstructions.get_instruction(id)
		add_item(instruction.display_name, id)
		
	get_popup().max_size.x = 400
