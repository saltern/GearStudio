class_name InstructionArgument extends RefCounted

var size: int		# u8
var value: int		# i64
var signed: bool


func serialize() -> PackedByteArray:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	
	match size:
		1:
			stream.put_u8(value)
		2:
			stream.put_u16(value)
		_:
			stream.put_u32(value)
	
	return stream.data_array


static func from_data(p_size: int, p_value: int, p_signed: bool) -> InstructionArgument:
	var inst: InstructionArgument = InstructionArgument.new()
	inst.size = p_size
	inst.value = p_value
	inst.signed = p_signed
	return inst
