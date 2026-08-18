class_name BinArchive extends BinObject

var objects: Array[BinObject]


func serialize() -> PackedByteArray:
	var stream: PackedByteArray = []
	
	for object: BinObject in objects:
		stream.append_array(object.serialize())
	
	return stream


func deserialize(bin_data: PackedByteArray, is_big_endian: bool) -> void:
	#TODO!!
	pass
