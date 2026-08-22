class_name BinAudioWBND extends BinRawData

const SIGNATURE: int = 0x444E4257


static func identify(bin_data: PackedByteArray, is_big_endian: bool) -> bool:
	#print("Identifying BinAudioWBND")
	var sign_bytes: PackedByteArray = bin_data.slice(0, 4)
	if is_big_endian:
		sign_bytes.bswap32(0)
	
	return sign_bytes.decode_u32(0) == SIGNATURE
