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
		var inst_name: String = ScriptInstructions.get_instruction_name(
			instruction.id
		)
		
		inst_name = "%s (" % inst_name
		
		for argument: int in instruction.arguments.size():
			if argument > 0:
				inst_name = "%s, " % inst_name
			
			inst_name = "%s%s" % [inst_name, instruction.arguments[argument].value]
		
		inst_name = "%s)" % inst_name
		
		add_item(inst_name)


func external_select(index: int) -> void:
	select(index)
