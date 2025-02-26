extends ItemList

signal instruction_selected

var item_to_id: Dictionary = {}


func _ready() -> void:
	var index: int = 0
	
	for id: int in ScriptInstructions.INSTRUCTION_DB:
		add_item(ScriptInstructions.get_instruction_name(id))
		item_to_id[index] = id
		index += 1

	item_activated.connect(instruction_select)


func instruction_select(index: int) -> void:
	instruction_selected.emit(item_to_id[index])
