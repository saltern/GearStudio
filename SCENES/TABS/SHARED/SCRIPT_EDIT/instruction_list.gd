extends ItemList

@export var action_spinbox: SteppingSpinBox

@onready var script_edit: ScriptEdit = owner


func _ready() -> void:
	action_spinbox.value_changed.connect(update)
	update(0)


func update(action_index: int) -> void:
	clear()
	
	var action: ScriptAction = script_edit.bin_script.actions[action_index]
	
	for instruction in action.instructions:
		add_item(instruction.display_name)
