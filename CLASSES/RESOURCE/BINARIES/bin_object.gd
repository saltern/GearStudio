@abstract class_name BinObject extends Serializable

const TERMINATOR: int = 0xFFFFFFFF
const SIZE_U16: int = 2
const SIZE_U32: int = 4


static func identify(_bin_data: PackedByteArray, _is_big_endian: bool) -> bool:
	return false


static func get_pointers(bin_data: PackedByteArray, is_big_endian: bool) -> PackedInt64Array:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.big_endian = is_big_endian
	stream.data_array = bin_data
	
	var pointers: PackedInt64Array = [stream.get_u32()]
	
	while pointers[-1] != TERMINATOR && stream.get_position() < stream.get_size() - 4:
		pointers.append(stream.get_u32())
	
	# Kick terminator
	pointers.resize(pointers.size() - 1)
	
	return pointers


static func finalize_pointers(pointers: PackedInt64Array, is_big_endian: bool) -> PackedByteArray:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.big_endian = is_big_endian
	
	var target_pointers: PackedInt64Array = pointers.duplicate()
	target_pointers.append(TERMINATOR)
	
	while target_pointers.size() % 4 != 0:
		target_pointers.append(TERMINATOR)
	
	# Adjust addresses
	for p: int in pointers.size():
		target_pointers[p] += SIZE_U32 * target_pointers.size()
	
	# Pass bytes
	for pointer: int in target_pointers:
		stream.put_u32(pointer)
	
	return stream.data_array
