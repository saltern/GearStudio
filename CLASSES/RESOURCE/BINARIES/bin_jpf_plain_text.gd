class_name BinJPFPlainText extends BinObject

const CHARIDX_SIGNATURE: int = 0x082A2000

var char_index: PackedByteArray
var sprites: Array[BinSprite]


static func identify(bin_data: PackedByteArray, is_big_endian: bool) -> bool:
	var pointers: PackedInt64Array = get_pointers(bin_data, is_big_endian)
	
	if pointers.size() < 3:
		return false
	
	var cursor_char_idx: int = pointers[0]
	if cursor_char_idx + 0x03 >= bin_data.size():
		return false
	
	var char_idx_check: bool = \
		bin_data.decode_u32(cursor_char_idx) == CHARIDX_SIGNATURE
	
	var cursor_sprite: int = pointers[1]
	
	if cursor_sprite + 0x05 >= bin_data.size():
		return false
	
	var sprite_check: bool = BinSprite.identify(
		bin_data.slice(pointers[1], pointers[2]), is_big_endian
	)
	
	return char_idx_check && sprite_check


func serialize() -> PackedByteArray:
	# Include pointer to first object
	var pointers	: PackedInt64Array = [0]
	var data		: PackedByteArray = []
	var stream		: StreamPeerBuffer = StreamPeerBuffer.new()
	
	stream.big_endian = big_endian
	
	# Add character index to data block
	data.append_array(char_index)
	
	# Add sprites to data block
	for sprite: BinSprite in sprites:
		pointers.append(data.size())
		data.append_array(sprite.serialize())
	
	# Write pointers
	stream.put_data(finalize_pointers(pointers))
	
	# Write data
	stream.put_data(data)
	
	return stream.data_array


func deserialize(bin_data: PackedByteArray, is_big_endian: bool) -> void:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.big_endian = is_big_endian
	big_endian = is_big_endian
	
	var pointers: PackedInt64Array = get_pointers(bin_data, big_endian)
	pointers.append(bin_data.size()) # Auxiliary pointer for deserialization
	
	char_index = bin_data.slice(pointers[0], pointers[1])
	
	for p: int in pointers.size() - 1:
		var slice: PackedByteArray = bin_data.slice(pointers[p], pointers[p + 1])
		
		if !BinSprite.identify(slice, big_endian):
			continue
		
		var sprite: BinSprite = BinSprite.new()
		sprite.deserialize(slice, big_endian)
		sprites.append(sprite)
