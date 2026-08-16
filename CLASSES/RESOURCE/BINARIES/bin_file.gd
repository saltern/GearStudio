class_name BinFile extends BinObject

var objects: Array[BinObject]


func serialize() -> PackedByteArray:
	var output: PackedByteArray = []
	
	for object: BinObject in objects:
		output.append_array(object.serialize())
	
	return output


func deserialize(bin_data: PackedByteArray) -> BinObject:
	#TODO!!!
	return BinFile.new()
