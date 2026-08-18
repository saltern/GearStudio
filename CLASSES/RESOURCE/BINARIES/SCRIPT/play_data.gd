class_name PlayData extends BinObject

var variables: PlayVariables
var chain_tables: Array[ChainTable]


func serialize() -> PackedByteArray:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.big_endian = big_endian
	
	stream.put_data(variables.serialize())
	
	for table: ChainTable in chain_tables:
		stream.put_data(table.serialize())
	
	return stream.data_array


func deserialize(bin_data: PackedByteArray, is_big_endian: bool) -> void:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.data_array = bin_data
	stream.big_endian = is_big_endian
	big_endian = is_big_endian

	variables = PlayVariables.new()
	variables.deserialize(bin_data, is_big_endian)
	
	var chain_table_count: int = 1
	
	# Apparently only two variants:
	# If the byte at 0x01 is 0x05, there's five chain tables
	# Otherwise, there's only one
	if bin_data[0x01] == 0x05:
		chain_table_count = 5
	
	var cursor: int = 0x00
	
	for _i: int in chain_table_count:
		cursor += ChainTable.SIZE
		var slice: PackedByteArray = bin_data.slice(
			cursor, cursor + ChainTable.SIZE
		)
		
		var table: ChainTable = ChainTable.new()
		table.deserialize(slice, is_big_endian)
		
		chain_tables.append(table)
