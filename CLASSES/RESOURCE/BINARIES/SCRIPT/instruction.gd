class_name Instruction extends RefCounted

const ID_CELLBEGIN		: int = 0x00
const ID_SEMITRANS		: int = 0x06
const ID_SCALE			: int = 0x07
const ID_ROT			: int = 0x08
const ID_DRAW_NORMAL	: int = 0x10
const ID_DRAW_REVERSE	: int = 0x11
const ID_CELL_JUMP		: int = 0x27
const ID_PALETTE		: int = 0x3C
const ID_VISUAL			: int = 0x45
const ID_END_ACTION		: int = 0xFF

var id: int										# u8
var arguments: Array[InstructionArgument]


func serialize() -> PackedByteArray:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.put_u8(id)
	
	for argument: InstructionArgument in arguments:
		stream.put_data(argument.serialize())
	
	return stream.data_array


static func from_data(p_id: int, p_args: Array[InstructionArgument]) -> Instruction:
	var instruction: Instruction = Instruction.new()
	instruction.id = p_id
	instruction.arguments = p_args
	return instruction


func get_size() -> int:
	var size: int = 1
	
	for argument: InstructionArgument in arguments:
		size += argument.size
	
	return size


func get_argument(argument: int) -> int:
	argument = clampi(argument, 0, arguments.size())
	return arguments[argument].value


func set_argument(argument: int, value: int) -> void:
	argument = clampi(argument, 0, arguments.size())
	arguments[argument].value = value
