extends Node

# PaletteEdit
var pal_selection: Array[bool] = []
var pal_data: Array[Color] = []

# CellEdit
var box_data: Array[BoxInfo] = []
var sprite_index: int
var sprite_x_offset: int
var sprite_y_offset: int

# ScriptEdit
var instruction: Instruction


func _ready() -> void:
	pal_selection.resize(256)


# Wouldn't want to always return the same reference
func get_instruction() -> Instruction:
	if instruction == null:
		return null
	
	var new_instruction := Instruction.new()
	
	new_instruction.id = instruction.id
	new_instruction.display_name = instruction.display_name
	
	for argument in instruction.arguments:
		var new_argument := InstructionArgument.new()
		new_argument.display_name = argument.display_name
		new_argument.signed = argument.signed
		new_argument.value = argument.value
		new_argument.size = argument.size
		new_instruction.arguments.append(new_argument)
	
	return new_instruction
