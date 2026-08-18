class_name BinScriptableBlock extends BinObject

var scriptables: Array[BinScriptable]


static func identify(bin_data: PackedByteArray, is_big_endian: bool) -> bool:
	var pointers: PackedInt64Array = get_pointers(bin_data, is_big_endian)
	pointers.append(bin_data.size())
	
	for p: int in pointers.size():
		var obj: PackedByteArray = bin_data.slice(
			pointers[p], pointers[p + 1]
		)
		
		# As far as I can tell only archive_jpf.bin has a BinScriptableBlock
		# object, and every scriptable has 3 pointers: cells, sprites, scripts
		if get_pointers(obj, is_big_endian).size() != 3:
			return false
	
	var scriptable: PackedByteArray = bin_data.slice(
		pointers[0], pointers[1]
	)
	
	return BinScriptable.identify(scriptable, is_big_endian)


func serialize() -> PackedByteArray:
	var pointers: PackedInt64Array = []
	var data: PackedByteArray = []
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.big_endian = big_endian
	
	for scriptable: BinScriptable in scriptables:
		pointers.append(data.size())
		data.append_array(scriptable.serialize())
	
	stream.put_data(finalize_pointers(pointers))
	stream.put_data(data)
	
	return stream.data_array


func deserialize(bin_data: PackedByteArray, is_big_endian: bool) -> void:
	var pointers: PackedInt64Array = get_pointers(bin_data, is_big_endian)
	pointers.append(bin_data.size())
	
	for p: int in pointers.size() - 1:
		var slice: PackedByteArray = bin_data.slice(pointers[p], pointers[p + 1])
		var scriptable: BinScriptable = BinScriptable.new()
		scriptable.deserialize(slice, is_big_endian)
		scriptables.append(scriptable)
