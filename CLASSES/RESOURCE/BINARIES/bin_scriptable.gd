class_name BinScriptable extends BinObject

var name: String
var cells: BinCellBlock
var sprites: BinSpriteBlock
var scripts: BinScript
var palettes: BinSpriteBlock
var ex_scripts: BinScript


static func identify(bin_data: PackedByteArray, is_big_endian: bool) -> bool:
	var pointers: PackedInt64Array = get_pointers(bin_data, is_big_endian)
	pointers.append(bin_data.size()) # Auxiliary pointer
	
	# Need at least 1 sprite
	if pointers.size() < 3:
		return false
	
	# Cells, sprites, scripts, palettes, EX scripts (#Reload), auxiliary pointer
	if pointers.size() > 6:
		return false
	
	# Speedup for player objects
	if pointers.size() > 4:
		var pal_0_address: int = pointers[3] + bin_data.decode_u32(pointers[3])
		var pal_1_address: int = pointers[3] + bin_data.decode_u32(pointers[3] + 0x4)
		var slice: PackedByteArray = bin_data.slice(pal_0_address, pal_1_address)
		
		if !BinSprite.identify(slice, is_big_endian):
			return false
	
	# Cell check
	var cell_block: PackedByteArray = bin_data.slice(pointers[0], pointers[1])
	var cell_pointers: PackedInt64Array = get_pointers(cell_block, is_big_endian)
	cell_pointers.append(cell_block.size()) # Auxiliary pointer
	
	if cell_pointers.size() < 2:
		return false
	
	var cell_slice: PackedByteArray = cell_block.slice(cell_pointers[0], cell_pointers[1])
	
	if !BinCell.identify(cell_slice, is_big_endian):
		return false
	
	# Sprite check
	var sprite_block: PackedByteArray = bin_data.slice(pointers[1], pointers[2])
	var sprite_pointers: PackedInt64Array = get_pointers(sprite_block, is_big_endian)
	sprite_pointers.append(sprite_block.size()) # Auxiliary pointer
	
	var sprite_slice: PackedByteArray = sprite_block.slice(sprite_pointers[0], sprite_pointers[1])
	
	if !BinSprite.identify(sprite_slice, is_big_endian):
		return false
	
	return true


func serialize() -> PackedByteArray:
	var pointers: PackedInt64Array = []
	var data: PackedByteArray = []
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.big_endian = big_endian

	# Cells
	pointers.append(0)
	data.append_array(cells.serialize())
	
	# Sprites
	pointers.append(data.size())
	data.append_array(sprites.serialize())
	
	# Scripts
	pointers.append(data.size())
	data.append_array(scripts.serialize())
	
	# Palettes
	if palettes.has_sprites():
		pointers.append(data.size())
		data.append_array(palettes.serialize())
	
	# EX Scripts
	if ex_scripts != null:
		pointers.append(data.size())
		data.append_array(ex_scripts.serialize())
	
	# Write
	stream.put_data(finalize_pointers(pointers, big_endian))
	stream.put_data(data)
	
	return stream.data_array


func deserialize(bin_data: PackedByteArray, is_big_endian: bool) -> void:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.data_array = bin_data
	stream.big_endian = is_big_endian
	big_endian = is_big_endian
	
	var pointers: PackedInt64Array = get_pointers(bin_data, is_big_endian)
	pointers.append(bin_data.size()) # Auxiliary pointer
	
	var cell_block: PackedByteArray = bin_data.slice(pointers[0], pointers[1])
	cells = BinCellBlock.new()
	cells.deserialize(cell_block, is_big_endian)
	
	var sprite_block: PackedByteArray = bin_data.slice(pointers[1], pointers[2])
	sprites = BinSpriteBlock.new()
	sprites.deserialize(sprite_block, is_big_endian)
	
	if pointers.size() > 3:
		var script_block: PackedByteArray = bin_data.slice(pointers[2], pointers[3])
		scripts = BinScript.new()
		
		if pointers.size() > 4:
			scripts.has_play_data = true
		
		scripts.deserialize(script_block, is_big_endian)
	
	if pointers.size() > 4:
		var palette_block: PackedByteArray = bin_data.slice(pointers[3], pointers[4])
		palettes = BinSpriteBlock.new()
		palettes.deserialize(palette_block, is_big_endian)
	
	# Reload EX scripts
	#if pointers.size() > 5:
		#var ex_block: PackedByteArray = bin_data.slice(pointers[4], pointers[5])
		#ex_scripts = BinScript.new()
		#ex_scripts.deserialize(ex_block, is_big_endian)


func get_cell_count() -> int:
	return cells.cells.size()


func get_cell(index: int) -> BinCell:
	return cells.cells[index]


func get_sprite_count() -> int:
	return sprites.sprites.size()


func get_sprite(index: int) -> BinSprite:
	return sprites.sprites[index]


func has_script() -> bool:
	return scripts != null


func has_palettes() -> bool:
	return palettes != null


func get_palette_count() -> int:
	if not has_palettes():
		return 0
	
	return palettes.get_sprite_count()


func get_palette(index: int) -> BinSprite:
	if not has_palettes():
		index = clampi(index, 0, sprites.get_sprite_count() - 1)
		return sprites.sprites[index]
	
	index = clampi(index, 0, palettes.sprites.size() - 1)
	return palettes.sprites[index]


func get_palette_array(index: int) -> PackedByteArray:
	return get_palette(index).palette
