class_name BinScript extends BinObject

var has_play_data: bool
var play_data: Array[PlayData]
var actions: Array[Action]


func serialize() -> PackedByteArray:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.big_endian = big_endian
	
	for data_set: PlayData in play_data:
		stream.put_data(data_set.serialize())
	
	for action: Action in actions:
		stream.put_data(action.serialize())
	
	# Terminator
	stream.put_u8(0xFD)
	stream.put_u8(0x00)
	
	stream.resize((stream.get_size() + 0xF) & ~0xF)
	
	return stream.data_array


func deserialize(bin_data: PackedByteArray, is_big_endian: bool) -> void:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.data_array = bin_data
	stream.big_endian = is_big_endian
	big_endian = is_big_endian
	
	var cursor: int = 0x00
	
	if has_play_data:
		var new_pd: PlayData = PlayData.new()
		new_pd.deserialize(bin_data, is_big_endian)
		play_data.append(new_pd)
		
		# Place cursor at end of play data
		if bin_data[0x01] < 0x81 && bin_data[0x01] > 0x02:
			if bin_data[0x01] == 0x05:
				cursor = 0x300
			else:
				cursor = 0x100
				
				if bin_data[0x50] & 0x01 > 0:
					cursor = 0x180
				
				if bin_data[0x50] & 0x02 > 0:
					cursor += 0x80
				
				if bin_data[0x50] & 0x04 > 0:
					cursor += 0x80
				
				if bin_data[0x50] & 0x08 > 0:
					cursor += 0x80
		else:
			cursor = 0x80
		
		# Isuka hack
		if bin_data[cursor] == 0xE5:
			var slice: PackedByteArray = bin_data.slice(cursor, cursor * 2)
			var isuka_pd: PlayData = PlayData.new()
			isuka_pd.deserialize(slice, is_big_endian)
			play_data.append(isuka_pd)
			cursor *= 2
	
	stream.seek(cursor)
	
	while stream.get_position() < bin_data.size():
		if stream.get_u16() == 0x00FD:
			break
		
		var action: Action = Action.new()
		action.deserialize(
			bin_data.slice(stream.get_position(), bin_data.size()),
			is_big_endian
		)
		
		actions.append(action)
		
		stream.seek(stream.get_position() + action.get_size())
