class_name BinRawData extends BinObject

var data: PackedByteArray


static func identify(_bin_data: PackedByteArray, _is_big_endian: bool) -> bool:
	return true


func serialize() -> PackedByteArray:
	return data


func deserialize(bin_data: PackedByteArray, _is_big_endian: bool) -> void:
	data = bin_data
