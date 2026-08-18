class_name BinWiiTPL extends BinObject

const SIGNATURE: int = 0x30AF2000

var data: PackedByteArray


static func identify(bin_data: PackedByteArray, _is_big_endian: bool) -> bool:
	return bin_data.decode_u32(0) == SIGNATURE


func serialize() -> PackedByteArray:
	return data


func deserialize(bin_data: PackedByteArray, _is_big_endian: bool) -> void:
	data = bin_data
