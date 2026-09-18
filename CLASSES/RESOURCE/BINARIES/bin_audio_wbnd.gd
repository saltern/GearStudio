class_name BinAudioWBND extends BinRawData

#const SIGNATURE: int = 0x444E4257
const SIGNATURE: int = 0x57424E44


static func identify(bin_data: PackedByteArray, is_big_endian: bool) -> bool:
	#print("Identifying BinAudioWBND")
	
	if bin_data.size() < 4:
		return false
	
	var sign_bytes: PackedByteArray = bin_data.slice(0, 4)
	if is_big_endian:
		sign_bytes.bswap32(0)
	
	return sign_bytes.decode_u32(0) == SIGNATURE
