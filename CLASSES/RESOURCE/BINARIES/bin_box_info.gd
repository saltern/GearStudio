class_name BinBoxInfo extends BinObject

const SIZE: int = 0xC
const ADDRESS_TYPE: int = 0x08

enum Type {
	HITBOX_ALT,
	HITBOX,
	HURTBOX,
	REGION_BACK,
	COLLISION_EXTEND,
	SPECIAL,
	REGION_FRONT,
}

var x_offset: int		# i16
var y_offset: int		# i16
var width: int			# u16
var height: int			# u16
var type: Type			# u16
var crop_x_offset: int	# i8
var crop_y_offset: int	# i8


static func identify(bin_data: PackedByteArray, _is_big_endian: bool) -> bool:
	if bin_data.size() != SIZE:
		return false
	
	return true


func serialize() -> PackedByteArray:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.big_endian = big_endian
	
	stream.put_16(x_offset)
	stream.put_16(y_offset)
	stream.put_u16(width)
	stream.put_u16(height)
	stream.put_u16(type)
	stream.put_8(crop_x_offset)
	stream.put_8(crop_y_offset)
	
	return stream.data_array


func deserialize(bin_data: PackedByteArray, is_big_endian: bool) -> void:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.data_array = bin_data
	stream.big_endian = is_big_endian
	
	x_offset = stream.get_16()
	y_offset = stream.get_16()
	width = stream.get_u16()
	height = stream.get_u16()
	type = stream.get_u16() as Type
	crop_x_offset = stream.get_8()
	crop_y_offset = stream.get_8()
