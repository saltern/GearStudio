class_name BinAudioVAGp extends BinRawData

const SIGNATURE: int = 0x56414770


static func identify(bin_data: PackedByteArray, is_big_endian: bool) -> bool:
	var pointers: PackedInt64Array = get_pointers(bin_data, is_big_endian)
	var sign_bytes: PackedByteArray = bin_data.slice(pointers[0], pointers[0] + 4)
	
	if sign_bytes.size() < 0x4:
		return false
	
	if is_big_endian:
		sign_bytes.bswap32(0)
	
	return sign_bytes.decode_u32(0) == SIGNATURE
