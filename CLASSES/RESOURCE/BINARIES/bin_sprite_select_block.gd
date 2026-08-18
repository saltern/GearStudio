class_name BinSpriteSelectBlock extends BinSpriteBlock

var cursor_mask: BinCursorMask


static func identify(bin_data: PackedByteArray, is_big_endian: bool) -> bool:
	var pointers: PackedInt64Array = get_pointers(bin_data, is_big_endian)
	pointers.append(bin_data.size()) # Auxiliary fake pointer
	
	for p: int in pointers.size() - 1:
		var slice: PackedByteArray = bin_data.slice(pointers[p], pointers[p] + 1)
		
		if !BinSprite.identify(slice, is_big_endian):
			if !BinCursorMask.identify(slice, is_big_endian):
				return false
	
	return true


func serialize() -> PackedByteArray:
	var pointers: PackedInt64Array = []
	var data: PackedByteArray = []
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.big_endian = big_endian
	
	for sprite: BinSprite in sprites:
		pointers.append(data.size())
		data.append_array(sprite.serialize())
	
	pointers.append(data.size())
	data.append_array(cursor_mask.serialize())
	
	stream.put_data(finalize_pointers(pointers))
	stream.put_data(data)
	
	return stream.data_array


func deserialize(bin_data: PackedByteArray, is_big_endian: bool) -> void:
	var pointers: PackedInt64Array = get_pointers(bin_data, is_big_endian)
	pointers.append(bin_data.size()) # Auxiliary deserialization pointer
	
	# Gather all sprites
	for p: int in pointers.size() - 2:
		var slice: PackedByteArray = bin_data.slice(pointers[p], pointers[p + 1])
		var sprite: BinSprite = BinSprite.new()
		sprite.deserialize(slice, is_big_endian)
		sprites.append(sprite)
	
	# Load cursor mask
	var mask_data: PackedByteArray = bin_data.slice(pointers[-2], pointers[-1])
	cursor_mask = BinCursorMask.new()
	cursor_mask.deserialize(mask_data, is_big_endian)
