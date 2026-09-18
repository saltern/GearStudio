class_name BinWiiTPL extends BinRawData

const SIGNATURE: int = 0x30AF2000


static func identify(bin_data: PackedByteArray, _is_big_endian: bool) -> bool:
	#print("Identifying BinWiiTPL")
	
	if bin_data.size() < 4:
		return false
	
	return bin_data.decode_u32(0) == SIGNATURE
