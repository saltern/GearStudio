extends ItemList

@export var action_spinbox: SteppingSpinBox

@onready var script_edit: ScriptEdit = owner


func _ready() -> void:
	script_edit.action_loaded.connect(update)
	script_edit.action_select_instruction.connect(external_select)
	item_selected.connect(script_edit.script_instruction_select)


func update() -> void:
	clear()
	
	var action: ScriptAction = script_edit.this_action
	
	for instruction in action.instructions:
		add_item(ScriptInstructions.get_instruction_name(instruction.id))


func external_select(index: int) -> void:
	select(index)
