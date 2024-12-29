extends ItemList

@export var action_spinbox: SteppingSpinBox

@onready var script_edit: ScriptEdit = owner


func _ready() -> void:
	script_edit.action_loaded.connect(update)
	item_selected.connect(script_edit.script_instruction_select)


func update() -> void:
	clear()
	
	var action: ScriptAction = script_edit.this_action
	
	for instruction in action.instructions:
		add_item(instruction.display_name)
