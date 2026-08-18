class_name BinCell extends BinObject

const SIZE: int = 0x10

var boxes: Array[BinBoxInfo]
var sprite_x_offset: int	# i16
var sprite_y_offset: int	# i16
var unknown_1: int			# u32
var sprite_index: int		# u16
var unknown_2: int			# u16


static func identify(bin_data: PackedByteArray, is_big_endian: bool) -> bool:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.data_array = bin_data
	stream.big_endian = is_big_endian
	
	var box_count: int = stream.get_u32()
	var target_size: int = SIZE + BinBoxInfo.SIZE * box_count
	target_size = (target_size + 0xF) & ~0xF
	
	return bin_data.size() == target_size


func serialize() -> PackedByteArray:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.big_endian = big_endian
	
	stream.put_u32(boxes.size())
	
	for box: BinBoxInfo in boxes:
		stream.put_data(box.serialize())
	
	stream.put_16(sprite_x_offset)
	stream.put_16(sprite_y_offset)
	stream.put_u32(unknown_1)
	stream.put_u16(sprite_index)
	stream.put_u16(unknown_2)
	
	while stream.get_size() % 0x10 != 0:
		stream.put_u8(0xFF)
	
	return stream.data_array


func deserialize(bin_data: PackedByteArray, is_big_endian: bool) -> void:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.big_endian = is_big_endian
	stream.data_array = bin_data
	
	var box_count: int = stream.get_u32()
	
	for box: int in box_count:
		var new_box: BinBoxInfo = BinBoxInfo.new()
		new_box.deserialize(stream.get_data(BinBoxInfo.SIZE), is_big_endian)
		boxes.append(new_box)
	
	sprite_x_offset = stream.get_16()
	sprite_y_offset = stream.get_16()
	unknown_1 = stream.get_u32()
	sprite_index = stream.get_u16()
	unknown_2 = stream.get_u16()
