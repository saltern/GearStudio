@abstract class_name BinObject extends Resource

const TERMINATOR: int = 0xFFFFFFFF

var big_endian: bool = false


static func identify(_bin_data: PackedByteArray) -> bool:
	return false

@abstract func serialize() -> PackedByteArray
@abstract func deserialize(bin_data: PackedByteArray, is_big_endian: bool) -> void


func get_pointers(bin_data: PackedByteArray) -> PackedInt64Array:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.big_endian = big_endian
	stream.data_array = bin_data
	
	var pointers: PackedInt64Array = []
	
	while pointers[-1] != TERMINATOR:
		pointers.append(stream.get_u32())
	
	# Kick terminator
	pointers.resize(pointers.size() - 1)
	
	return pointers
