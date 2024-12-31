extends ItemList

signal instruction_selected

var item_to_id: Dictionary = {}


func _ready() -> void:
	var index: int = 0
	
	for id: int in ScriptInstructions.INSTRUCTION_DB:
		var instruction: Instruction = ScriptInstructions.get_instruction(id)
		add_item(instruction.display_name)
		item_to_id[index] = id
		index += 1

	item_activated.connect(instruction_select)


func instruction_select(index: int) -> void:
	instruction_selected.emit(item_to_id[index])
