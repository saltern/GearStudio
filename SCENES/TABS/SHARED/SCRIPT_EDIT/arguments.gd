extends VBoxContainer

@export var action_index: SteppingSpinBox
@export var instruction_list: ItemList
@export var model_arg: HBoxContainer
@export var nothing_selected: Label

var instruction_index: int = -1

@onready var script_edit: ScriptEdit = owner


func _ready() -> void:
	script_edit.action_select_instruction.connect(create_controls)
	action_index.value_changed.connect(clear_controls.unbind(1))
	instruction_list.item_selected.connect(create_controls)


func clear_controls() -> void:
	nothing_selected.show()
	
	instruction_index = -1
	
	for child in get_children():
		child.queue_free()


func create_controls(index: int) -> void:
	clear_controls()
	nothing_selected.hide()
	
	var instruction: Instruction = script_edit.script_instruction_get(index)
	
	instruction_index = index
	
	for arg_number in instruction.arguments.size():
		var argument: InstructionArgument = instruction.arguments[arg_number]
		
		var new_control: HBoxContainer = model_arg.duplicate()
		new_control.show()
		var label: Label = new_control.get_child(0)
		var value: SteppingSpinBox = new_control.get_child(1)
		
		label.text = argument.display_name
		
		if argument.signed:
			value.min_value = -pow(2, argument.size * 8) / 2
			value.max_value = (pow(2, argument.size * 8) / 2) - 1
		else:
			value.max_value = pow(2, argument.size * 8) - 1
		
		value.value = argument.value
		value.value_changed.connect(set_argument.bind(arg_number))
		
		add_child(new_control)


# I'd usually invert this order, but .bind() adds arguments at the end
func set_argument(value: int, argument: int) -> void:
	script_edit.script_argument_set(instruction_index, argument, value)
