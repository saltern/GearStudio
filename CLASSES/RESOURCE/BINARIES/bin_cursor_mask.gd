class_name BinCursorMask extends BinObject

var width: int
var height: int
var pixels: PackedByteArray


static func identify(bin_data: PackedByteArray, is_big_endian: bool) -> bool:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.data_array = bin_data
	stream.big_endian = is_big_endian
	
	var w: int = stream.get_u32()
	var h: int = stream.get_u32()
	var target_size: int = (SIZE_U32 * 2) + (w * h)
	target_size += target_size % 0x10
			
	return bin_data.size() == target_size


func serialize() -> PackedByteArray:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.big_endian = big_endian
	
	stream.put_u32(width)
	stream.put_u32(height)
	stream.put_data(pixels)
	
	var target_size: int = (SIZE_U32 * 2) + (width * height)
	target_size = (target_size + 0xF) & ~0xF
	stream.resize(target_size)
	
	return stream.data_array


func deserialize(bin_data: PackedByteArray, is_big_endian: bool) -> void:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.data_array = bin_data
	stream.big_endian = is_big_endian
	
	width = stream.get_u32()
	height = stream.get_u32()
	pixels = stream.get_data(width * height)
