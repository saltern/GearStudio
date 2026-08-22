class_name BinCell extends BinObject

const SIZE: int = 0x10

var boxes: Array[BinBoxInfo]
var sprite_x_offset: int	# i16
var sprite_y_offset: int	# i16
var unknown_1: int			# u32
var sprite_index: int		# u16
var unknown_2: int			# u16


static func identify(bin_data: PackedByteArray, is_big_endian: bool) -> bool:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.data_array = bin_data
	stream.big_endian = is_big_endian
	
	var box_count: int = stream.get_u32()
	var target_size: int = SIZE + BinBoxInfo.SIZE * box_count
	target_size = (target_size + 0xF) & ~0xF
	
	return bin_data.size() == target_size


func serialize() -> PackedByteArray:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.big_endian = big_endian
	
	stream.put_u32(boxes.size())
	
	for box: BinBoxInfo in boxes:
		stream.put_data(box.serialize())
	
	stream.put_16(sprite_x_offset)
	stream.put_16(sprite_y_offset)
	stream.put_u32(unknown_1)
	stream.put_u16(sprite_index)
	stream.put_u16(unknown_2)
	
	while stream.get_size() % 0x10 != 0:
		stream.put_u8(0xFF)
	
	return stream.data_array


func deserialize(bin_data: PackedByteArray, is_big_endian: bool) -> void:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.big_endian = is_big_endian
	stream.data_array = bin_data
	
	var box_count: int = stream.get_u32()
	
	for box: int in box_count:
		var new_box: BinBoxInfo = BinBoxInfo.new()
		new_box.deserialize(stream.get_data(BinBoxInfo.SIZE), is_big_endian)
		boxes.append(new_box)
	
	sprite_x_offset = stream.get_16()
	sprite_y_offset = stream.get_16()
	unknown_1 = stream.get_u32()
	sprite_index = stream.get_u16()
	unknown_2 = stream.get_u16()


func rebuild_sprite(sprite: BinSprite, visual_1: bool) -> Array[CropInfo]:
	var regions: Array[BinBoxInfo] = []
	
	for box: BinBoxInfo in boxes:
		if box.is_region():
			regions.append(box)
	
	if regions.is_empty():
		var single_crop: CropInfo = CropInfo.new()
		single_crop.x = 0
		single_crop.y = 0
		single_crop.texture = sprite.get_texture()
		return [single_crop]
	
	var results: Array[CropInfo] = []
	
	var pow2_w: int = sprite.texture_width
	var pow2_h: int = sprite.texture_height
	var pow2_image: Image = Image.create_empty(
		pow2_w, pow2_h, false, Image.FORMAT_L8
	)
	
	var src_rect: Rect2i = Rect2i(0, 0, sprite.width, sprite.height)
	
	pow2_image.blit_rect(sprite.image, src_rect, Vector2i.ZERO)
	
	for region: BinBoxInfo in regions:
		var x_origin: int
		var y_origin: int
		
		if region.x_offset < 0:
			x_origin = wrap(region.x_offset, 0, sprite.width - 1)
		else:
			x_origin = wrap(region.x_offset, 0, pow2_w - 1)
		
		if region.y_offset < 0:
			y_origin = wrap(region.y_offset, 0, sprite.height - 1)
		else:
			y_origin = wrap(region.y_offset, 0, pow2_h - 1)
		
		# Allocate target pixel vector
		var pixel_vec: PackedByteArray = []
		pixel_vec.resize(region.width * region.height)
		pixel_vec.fill(0x00)
		
		# Copy
		for row: int in region.height:
			for col: int in region.width:
				var source_x: int = wrap(x_origin + col, 0, pow2_w - 1)
				var source_y: int = wrap(y_origin + row, 0, pow2_h - 1)
				
				if visual_1 && region.type == BinBoxInfo.Type.REGION_FRONT:
					source_y += region.height - row * 2
				
				var source: int = source_y * pow2_w + source_x
				var target: int = row * region.width + col
				
				pixel_vec[target] = pow2_image.get_data()[source]
	
		var image: Image = Image.create_from_data(
			region.width, region.height, false, Image.FORMAT_L8, pixel_vec
		)
		
		var texture: ImageTexture = ImageTexture.create_from_image(image)
		
		var this_crop: CropInfo = CropInfo.new()
		this_crop.x = region.x_offset + region.crop_x_offset * 8
		this_crop.y = region.y_offset + region.crop_y_offset * 8
		this_crop.texture = texture
		results.append(this_crop)
	
	return results
