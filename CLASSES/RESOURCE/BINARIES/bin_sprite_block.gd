class_name BinSpriteBlock extends BinObject

var sprites: Array[BinSprite]

var single_mode: bool = false


static func identify(bin_data: PackedByteArray, is_big_endian: bool) -> bool:
	# Unnecessary?
	if BinSprite.identify(bin_data, is_big_endian):
		return true
	
	#print("Identifying BinSpriteBlock")
	var pointers: PackedInt64Array = get_pointers(bin_data, is_big_endian)
	pointers.append(bin_data.size()) # Auxiliary fake pointer
	
	for p: int in pointers.size() - 1:
		var slice: PackedByteArray = bin_data.slice(pointers[p], pointers[p] + 1)
		if !BinSprite.identify(slice, is_big_endian):
			return false
	
	return true


func serialize() -> PackedByteArray:
	var pointers: PackedInt64Array = []
	var data: PackedByteArray = []
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.big_endian = big_endian
	
	if single_mode:
		stream.put_data(sprites[0].serialize())
		return stream.data_array
		# Early cutoff
	
	for sprite: BinSprite in sprites:
		pointers.append(data.size())
		data.append_array(sprite.serialize())
	
	stream.put_data(finalize_pointers(pointers, big_endian))
	stream.put_data(data)
	
	return stream.data_array


func deserialize(bin_data: PackedByteArray, is_big_endian: bool) -> void:
	if single_mode:
		var sprite: BinSprite = BinSprite.new()
		sprite.deserialize(bin_data, is_big_endian)
		sprites = [sprite]
		return
		# Early cutoff
	
	var pointers: PackedInt64Array = get_pointers(bin_data, is_big_endian)
	pointers.append(bin_data.size())
	
	for p: int in pointers.size() - 1:
		var slice: PackedByteArray = bin_data.slice(pointers[p], pointers[p + 1])
		var sprite: BinSprite = BinSprite.new()
		sprite.deserialize(slice, is_big_endian)
		sprites.append(sprite)


func has_sprites() -> bool:
	return sprites.size() > 0


func get_sprite_count() -> int:
	return sprites.size()


func get_sprite(index: int) -> BinSprite:
	return sprites[index]


func get_palette(index: int) -> PackedByteArray:
	return sprites[index].palette
