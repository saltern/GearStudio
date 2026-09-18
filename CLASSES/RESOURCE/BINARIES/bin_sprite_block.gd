class_name BinSpriteBlock extends BinObject

signal sprite_deserialized

var sprites: Array[BinSprite]

var single_mode: bool = false

var deserialize_count: int = 0
var dictionary: Dictionary = {}


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
		dictionary = { 0: sprite }
		deserialization_finish()
		return
		# Early cutoff
	
	var pointers: PackedInt64Array = get_pointers(bin_data, is_big_endian)
	pointers.append(bin_data.size())
	
	deserialize_count = pointers.size() - 1
	sprite_deserialized.connect(on_sprite_deserialized)
	
	for p: int in pointers.size() - 1:
		var slice: PackedByteArray = bin_data.slice(pointers[p], pointers[p + 1])
		
		WorkerThreadPool.add_task(
			deserialize_thread.bind(
				p, slice, is_big_endian
			)
		)


func deserialize_thread(
	number: int, bin_data: PackedByteArray, is_big_endian: bool
) -> void:
	var sprite: BinSprite = BinSprite.new()
	sprite.deserialize(bin_data, is_big_endian)
	dictionary[number] = sprite
	sprite_deserialized.emit.call_deferred(WorkerThreadPool.get_caller_task_id())


func on_sprite_deserialized(task_id: int) -> void:
	WorkerThreadPool.wait_for_task_completion(task_id)
	deserialize_count -= 1
	
	if deserialize_count > 0:
		return
	
	deserialization_finish()#.call_deferred()


func deserialization_finish() -> void:
	dictionary.sort()
	
	for i: int in dictionary.keys():
		sprites.append(dictionary[i])
	
	deserialized.emit.call_deferred()


func has_sprites() -> bool:
	return sprites.size() > 0


func get_sprite_count() -> int:
	return sprites.size()


func set_sprite(index: int, sprite: BinSprite) -> void:
	sprites[index] = sprite


func get_sprite(index: int) -> BinSprite:
	return sprites[index]


func get_palette(index: int) -> PackedByteArray:
	return sprites[index].palette
