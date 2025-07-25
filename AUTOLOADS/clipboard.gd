extends Node

# PaletteEdit
var pal_selection: Array[bool] = []
var pal_data: Array[Color] = []

# CellEdit
var cell: Cell
var box_data: Array[BoxInfo] = []
var sprite_index: int = -1
var sprite_x_offset: int = 0
var sprite_y_offset: int = 0
var unknown_1: int = 0
var unknown_2: int = 0

# ScriptEdit
var script_action: ScriptAction
var instruction: Instruction


func _ready() -> void:
	pal_selection.resize(256)


func has_sprite_info() -> bool:
	return sprite_index != -1


func set_sprite_info(source_cell: Cell) -> void:
	sprite_index = source_cell.sprite_index
	sprite_x_offset = source_cell.sprite_x_offset
	sprite_y_offset = source_cell.sprite_y_offset
	unknown_1 = source_cell.unknown_1
	unknown_2 = source_cell.unknown_2


func set_box_data(
	source: Array[BoxInfo], selection: PackedInt32Array
) -> void:
	box_data.clear()
	for box in selection:
		box_data.append(source[box])


func get_box_data() -> Array[BoxInfo]:
	var return_array: Array[BoxInfo] = []
	
	for box in box_data:
		return_array.append(duplicate_box(box))
	
	return return_array


func duplicate_box(box: BoxInfo) -> BoxInfo:
	var new_box := BoxInfo.new()
	
	new_box.box_type = box.box_type
	new_box.x_offset = box.x_offset
	new_box.y_offset = box.y_offset
	new_box.width = box.width
	new_box.height = box.height
	new_box.crop_x_offset = box.crop_x_offset
	new_box.crop_y_offset = box.crop_y_offset
	
	return new_box


# Wouldn't want to always return the same reference
func get_script_action() -> ScriptAction:
	if script_action == null:
		return null
	
	return duplicate_script_action(script_action)


func get_instruction() -> Instruction:
	if instruction == null:
		return null

	return duplicate_instruction(instruction)


func duplicate_script_action(from_action: ScriptAction) -> ScriptAction:
	var new_script_action := ScriptAction.new()
	
	new_script_action.flags = from_action.flags
	new_script_action.lvflag = from_action.lvflag
	new_script_action.damage = from_action.damage
	new_script_action.flag2 = from_action.flag2
	
	for index in from_action.instructions:
		new_script_action.instructions.append(duplicate_instruction(index))
	
	return new_script_action


func duplicate_instruction(from_instruction: Instruction) -> Instruction:
	var new_instruction := Instruction.new()
	
	new_instruction.id = from_instruction.id
	
	for argument in from_instruction.arguments:
		var new_argument := InstructionArgument.new()
		new_argument.signed = argument.signed
		new_argument.value = argument.value
		new_argument.size = argument.size
		new_instruction.arguments.append(new_argument)
	
	return new_instruction
