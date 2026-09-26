class_name BinArchive extends BinObject

var objects: Array[BinObject]
var gallery: bool = false

var dictionary: Dictionary = {}
var task_count: int = 0
var task_start: int = 0


func serialize() -> PackedByteArray:
	var pointers: PackedInt64Array = []
	var data: PackedByteArray = []
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.big_endian = big_endian
	
	for object: BinObject in objects:
		pointers.append(data.size())
		data.append_array(object.serialize())
	
	stream.put_data(finalize_pointers(pointers, big_endian))
	stream.put_data(data)
	
	return stream.data_array


func deserialize(bin_data: PackedByteArray, is_big_endian: bool) -> void:
	if BinAudioWBND.identify(bin_data, is_big_endian):
		semaphore.post()
		return
	if BinAudioVAGp.identify(bin_data, is_big_endian):
		semaphore.post()
		return
	
	var pointers: PackedInt64Array = get_pointers(bin_data, is_big_endian)	
	
	GlobalSignals.progress_show("Loading...", pointers.size())
	
	pointers.append(bin_data.size()) # Auxiliary pointer
	
	for p: int in pointers.size() - 1:
		var slice: PackedByteArray = bin_data.slice(pointers[p], pointers[p + 1])
		var object: BinObject
	
		if BinAudioWBND.identify(slice, is_big_endian):
			object = BinAudioWBND.new()
		
		elif BinAudioVAGp.identify(slice, true):
			object = BinAudioVAGp.new()
		
		if BinSprite.identify(slice, is_big_endian):
			object = BinSpriteBlock.new()
			object.single_mode = true
		
		elif BinSpriteSelectBlock.identify(slice, is_big_endian):
			object = BinSpriteSelectBlock.new()
		
		elif BinSpriteBlock.identify(slice, is_big_endian):
			object = BinSpriteBlock.new()
		
		elif BinJPFPlainText.identify(slice, is_big_endian):
			object = BinJPFPlainText.new()
		
		elif BinWiiTPL.identify(slice, is_big_endian):
			object = BinWiiTPL.new()
		
		elif BinScriptable.identify(slice, is_big_endian):
			object = BinScriptable.new()
		
		elif BinScriptableBlock.identify(slice, is_big_endian):
			object = BinScriptableBlock.new()
		
		else:
			object = BinRawData.new()
		
		object.deserialize(slice, is_big_endian)
		object.semaphore.wait()
		objects.append(object)
		GlobalSignals.progress_advance()
	
	if is_gallery():
		gallery = true
		var array: Array[BinSprite] = []
		var block: BinSpriteBlock = BinSpriteBlock.new()
		
		for sprite: BinSprite in objects:
			array.append(sprite)
		
		block.sprites = array
		objects = [block]
	
	semaphore.post()


func is_gallery() -> bool:
	for object: BinObject in objects:
		if !object is BinSprite:
			return false
	
	return true


func get_object_count() -> int:
	return objects.size()


func get_object(index: int) -> BinObject:
	index = clampi(index, 0, objects.size() - 1)
	index = maxi(index, 0)
	return objects[index]
