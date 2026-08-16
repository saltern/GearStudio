class_name BinJPFPlainText extends BinObject

var char_index: PackedByteArray
var sprites: Array[BinSprite]


func serialize() -> PackedByteArray:
	# Include pointer to first object
	var pointers	: PackedInt32Array = [0]
	var data		: PackedByteArray = []
	var output		: StreamPeerBuffer = StreamPeerBuffer.new()
	
	output.big_endian = big_endian
	
	# Add character index to data block
	data.append_array(char_index)
	
	# Add sprites to data block
	for sprite: BinSprite in sprites:
		pointers.append(data.size())
		data.append_array(sprite.serialize())
	
	# Add terminators to pointers
	pointers.append(TERMINATOR)
	
	while pointers.size() % 0x10 != 0x00:
		pointers.append(TERMINATOR)
	
	# Add size of pointer block to each pointer
	for p: int in pointers.size():
		if pointers[p] == TERMINATOR:
			break
		
		pointers[p] += pointers.size()
	
	# Write pointers
	for p: int in pointers.size():
		output.put_u32(pointers[p])
	
	# Write data
	output.put_data(data)
	
	return output.data_array


func deserialize(bin_data: PackedByteArray, is_big_endian: bool) -> void:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.big_endian = is_big_endian
	big_endian = is_big_endian
	
	var pointers: PackedInt64Array = get_pointers(bin_data)
	
	char_index = bin_data.slice(pointers[0], pointers[1])
	
	for i: int in range(pointers[1], pointers[-1]):
		
