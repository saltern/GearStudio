class_name BinArchive extends BinObject

var objects: Array[BinObject]
var gallery: bool = false


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
	var pointers: PackedInt64Array = get_pointers(bin_data, is_big_endian)	
	pointers.append(bin_data.size()) # Auxiliary pointer

	for p: int in pointers.size() - 1:
		var slice: PackedByteArray = bin_data.slice(pointers[p], pointers[p + 1])
		var object: BinObject
		
		if BinAudioWBND.identify(slice, is_big_endian):
			print("Detected WBND audio")
			object = BinAudioWBND.new()
		
		elif BinAudioVAGp.identify(slice, true):
			print("Detected VAGp audio")
			object = BinAudioVAGp.new()
		
		elif BinSprite.identify(slice, is_big_endian):
			print("Detected single sprite")
			object = BinSpriteBlock.new()
			object.single_mode = true
		
		elif BinSpriteSelectBlock.identify(slice, is_big_endian):
			print("Detected sprite block + select cursor mask")
			object = BinSpriteSelectBlock.new()
		
		elif BinSpriteBlock.identify(slice, is_big_endian):
			print("Detected sprite block")
			object = BinSpriteBlock.new()
		
		elif BinJPFPlainText.identify(slice, is_big_endian):
			print("Detected JPF Plain Text")
			object = BinJPFPlainText.new()
		
		elif BinWiiTPL.identify(slice, is_big_endian):
			print("Detected Wii TPL")
			object = BinWiiTPL.new()
		
		elif BinScriptable.identify(slice, is_big_endian):
			print("Detected scriptable")
			object = BinScriptable.new()
		
		elif BinScriptableBlock.identify(slice, is_big_endian):
			print("Detected scriptable block")
			object = BinScriptableBlock.new()
		
		else:
			print("Falling back to unsupported")
			object = BinRawData.new()
		
		object.deserialize(slice, is_big_endian)
		objects.append(object)

	if is_gallery():
		gallery = true
		var array: Array[BinSprite] = []
		var block: BinSpriteBlock = BinSpriteBlock.new()
		
		for sprite: BinSprite in objects:
			array.append(sprite)
		
		block.sprites = array
		objects = [block]


func is_gallery() -> bool:
	for object: BinObject in objects:
		if !object is BinSprite:
			return false
	
	return true


func get_object_count() -> int:
	return objects.size()


func get_object(index: int) -> BinObject:
	index = clampi(index, 0, objects.size() - 1)
	return objects[index]
