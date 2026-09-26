class_name BinSpriteBlock extends BinObject

signal sprite_deserialized

@export var sprites: Array[BinSprite]
@export var single_mode: bool = false

var deserialize_count: int = -1


static func identify(bin_data: PackedByteArray, is_big_endian: bool) -> bool:
	if bin_data.size() < 1:
		return false
	
	var pointers: PackedInt64Array = get_pointers(bin_data, is_big_endian)
	pointers.append(bin_data.size()) # Auxiliary fake pointer
	
	if pointers[0] >= pointers[1]:
		return false
	
	for p: int in pointers.size() - 1:
		var slice: PackedByteArray = bin_data.slice(pointers[p], pointers[p + 1])
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
		#deserialized.emit.call_deferred()
		semaphore.post()
		return
		# Early cutoff
	
	var pointers: PackedInt64Array = get_pointers(bin_data, is_big_endian)
	pointers.append(bin_data.size())
	
	deserialize_count = pointers.size() - 1
	sprite_deserialized.connect(on_sprite_deserialized)
	
	sprites.clear()
	sprites.resize(deserialize_count)
	
	var slices: Array[PackedByteArray] = []
	
	for p: int in pointers.size() - 1:
		slices.append(bin_data.slice(pointers[p], pointers[p + 1]))
	
	WorkerThreadPool.add_group_task(
		deserialize_thread.bind(slices, is_big_endian), deserialize_count,
		-1, true
	)


func deserialize_thread(
	index: int, slices: Array[PackedByteArray], is_big_endian: bool
) -> void:
	var sprite: BinSprite = BinSprite.new()
	sprite.deserialize(slices[index], is_big_endian)
	sprites[index] = sprite
	
	sprite_deserialized.emit.call_deferred(
		WorkerThreadPool.get_caller_group_id()
	)


func on_sprite_deserialized(group_id: int) -> void:
	deserialize_count -= 1
	
	if deserialize_count != 0:
		return
	
	deserialize_count = -1
	WorkerThreadPool.wait_for_group_task_completion(group_id)
	semaphore.post()


func has_sprites() -> bool:
	return sprites.size() > 0


func get_sprite_count() -> int:
	return sprites.size()


func set_sprite(index: int, sprite: BinSprite) -> void:
	sprites[index] = sprite


func get_sprite(index: int) -> BinSprite:
	if index < 0 || index >= sprites.size():
		return null
	
	return sprites[index]


func get_palette(index: int) -> PackedByteArray:
	return sprites[index].palette
