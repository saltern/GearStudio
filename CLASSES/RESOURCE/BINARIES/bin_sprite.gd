class_name BinSprite extends BinObject

enum Mode {
	RAW,
	ACPR,
	PALETTE,
	MODE_5,
	GGXP,
}

enum CLUT {
	NONE,
	HALF,
	FULL,
}

# Header signature addresses
const ADDRESS_MODE			: int = 0x00
const ADDRESS_CLUT			: int = 0x02
const ADDRESS_DEPTH			: int = 0x04
const ADDRESS_WIDTH			: int = 0x06
const ADDRESS_HEIGHT		: int = 0x08
const ADDRESS_TEX_WIDTH		: int = 0x0A
const ADDRESS_TEX_HEIGHT	: int = 0x0C
const ADDRESS_HASH			: int = 0x0E

const ADDRESS_GGXP_CC		: int = 0x01
const ADDRESS_GGXP_WIDTH	: int = 0x02
const ADDRESS_GGXP_HEIGHT	: int = 0x04

const ADDRESS_HEADER_END	: int = 0x10

# Possible modes
const MODE_RAW				: int = 0x0000
const MODE_ACPR				: int = 0x0001
const MODE_PALETTE			: int = 0x0003
const MODE_5				: int = 0x0005
const MODE_GGXP8			: int = 0x13
const MODE_GGXP4			: int = 0x14

# GGX Plus compression values
const GGXP_UNCOMPRESSED		: int = 0x00
const GGXP_COMPRESSED		: int = 0x04

# CLUT values
const CLUT_NONE				: int = 0x0000
const CLUT_HALF				: int = 0x0010
const CLUT_FULL				: int = 0x0020

const COLOR_COUNT_4_HALF	: int = 0x08	# 8
const COLOR_COUNT_4_FULL	: int = 0x10	# 16
const COLOR_COUNT_8_HALF	: int = 0x80	# 128
const COLOR_COUNT_8_FULL	: int = 0x100	# 256

const COLOR_SIZE			: int = 0x04

const CLUT_SIZE_4_HALF		: int = COLOR_SIZE * COLOR_COUNT_4_HALF
const CLUT_SIZE_4_FULL		: int = COLOR_SIZE * COLOR_COUNT_4_FULL
const CLUT_SIZE_8_HALF		: int = COLOR_SIZE * COLOR_COUNT_8_HALF
const CLUT_SIZE_8_FULL		: int = COLOR_SIZE * COLOR_COUNT_8_FULL

# GGX Plus CLUT values
const GGXP_CLUT_NONE		: int = 0x0F
const GGXP_CLUT_HALF		: int = 0x02
const GGXP_CLUT_FULL		: int = 0x00

# Depth values
const DEPTH_4				: int = 0x0004
const DEPTH_8				: int = 0x0008

# Common format
const COMMON_MODES			: PackedInt32Array = [MODE_RAW, MODE_ACPR, MODE_PALETTE, MODE_5]
const COMMON_CLUT			: PackedInt32Array = [CLUT_NONE, CLUT_HALF, CLUT_FULL]
const COMMON_DEPTH			: PackedInt32Array = [DEPTH_4, DEPTH_8]

# GGX Plus sprites
const GGXP_MODES			: PackedInt32Array = [MODE_GGXP4, MODE_GGXP8]
const GGXP_COMPRESSION		: PackedInt32Array = [GGXP_UNCOMPRESSED, GGXP_COMPRESSED]
const GGXP_CLUT				: PackedInt32Array = [GGXP_CLUT_NONE, GGXP_CLUT_HALF, GGXP_CLUT_FULL]

# BMP files
const BITMAPCOREHEADER_SIZE	: int = 12
const BMP_COLOR_24			: int = 3
const BMP_COLOR_32			: int = 4

# Quantization parameters
const QUANT_DEFAULT_QUALITY	: int = 10

# Cached image and texture parameters
const IMAGE_EMPTY_W			: int = 1
const IMAGE_EMPTY_H			: int = 1
const IMAGE_MIPMAPS			: bool = false
const IMAGE_FORMAT			: Image.Format = Image.Format.FORMAT_L8


# Variables
var mode			: Mode
var clut			: CLUT
var bit_depth		: int:
	get:
		if bit_depth == DEPTH_4:
			return DEPTH_4
		else:
			return DEPTH_8
	set(value):
		if value == DEPTH_4:
			bit_depth = DEPTH_4
		else:
			bit_depth = DEPTH_8

var width			: int
var height			: int

var texture_width	: int:
	get:
		return pow(2, texture_width)
		
var texture_height	: int:
	get:
		return pow(2, texture_height)

var id_hash			: int
var manual_hash		: bool
var palette			: PackedByteArray:
	get:
		if clut == CLUT.NONE:
			return []
		else:
			return palette
	set(value):
		value.resize(COLOR_SIZE * get_color_count())
		palette = value
	
var pixels			: PackedByteArray

# Not serialized
var image			: Image
var texture			: ImageTexture


static func identify(bin_data: PackedByteArray, is_big_endian: bool) -> bool:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.data_array = bin_data
	stream.big_endian = is_big_endian
	
	var ggxp_mode: int = stream.get_u8()
	var ggxp_cc: int = stream.get_u8()
	
	if GGXP_MODES.has(ggxp_mode):
		if !GGXP_COMPRESSION.has(ggxp_cc >> 0x4):
			return false
		if !GGXP_CLUT.has(ggxp_cc & 0xF):
			return false
		
		return true
	
	stream.seek(0)
	var bin_mode: int = stream.get_u16()
	var bin_clut: int = stream.get_u16()
	var bin_bpp: int = stream.get_u16()
	
	if !COMMON_MODES.has(bin_mode)	: return false
	if !COMMON_CLUT.has(bin_clut)	: return false
	if !COMMON_DEPTH.has(bin_bpp)	: return false
	
	return true


func serialize() -> PackedByteArray:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()

	match mode:
		Mode.RAW:
			stream.put_u16(MODE_RAW)
		Mode.PALETTE:
			stream.put_u16(MODE_PALETTE)
		_:
			stream.put_u16(MODE_ACPR)

	match clut:
		CLUT.NONE:
			stream.put_u16(CLUT_NONE)
		CLUT.HALF:
			stream.put_u16(CLUT_HALF)
		CLUT.FULL:
			stream.put_u16(CLUT_FULL)

	# Depth
	stream.put_u16(bit_depth)

	# Width, height
	stream.put_u16(width)
	stream.put_u16(height)

	# Allocated texture width, height
	stream.put_u16(texture_width)
	stream.put_u16(texture_height)

	# Hash
	stream.put_u16(id_hash)

	# Palette
	if clut != CLUT.NONE:
		stream.put_data(palette)

	# Pixel data
	match mode:
		Mode.RAW:
			stream.put_data(pixels)
		Mode.PALETTE:
			pass
		_:
			stream.put_data(SpriteCompression.compress_acpr(pixels, bit_depth))

	return stream.data_array


func deserialize(bin_data: PackedByteArray, is_big_endian: bool) -> void:
	# Assumes this has already been identified as a sprite
	var ggxp_compressed: bool = false
	var pal_size: int
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.data_array = bin_data
	stream.big_endian = is_big_endian

	var bin_mode: int = stream.get_u8()

	# GGX Plus sprites
	if GGXP_MODES.has(bin_mode):
		mode = Mode.GGXP

		match bin_mode:
			MODE_GGXP4:
				bit_depth = DEPTH_4
			MODE_GGXP8:
				bit_depth = DEPTH_8
			_:
				push_error("BinSprite::deserialize() error! Invalid GGX Plus mode")
				return

		var ggxp_cc: int = stream.get_u8()

		# High nibble: compression value
		match ggxp_cc >> 4:
			GGXP_UNCOMPRESSED:
				ggxp_compressed = false
			GGXP_COMPRESSED:
				ggxp_compressed = true
			_:
				push_error("BinSprite::deserialize() error! Invalid GGX Plus compression")
				return

		# Low nibble: CLUT value
		match ggxp_cc & 0xF:
			GGXP_CLUT_NONE:
				clut = CLUT.NONE
			GGXP_CLUT_HALF:
				clut = CLUT.HALF
			GGXP_CLUT_FULL:
				clut = CLUT.FULL
			_:
				push_error("BinSprite::deserialize() error! Invalid GGX Plus CLUT")
				return

		width = stream.get_u16()
		height = stream.get_u16()

		# Texture size
		texture_width = get_texture_size(width)
		texture_height = get_texture_size(height)

		# Hash, palette
		pal_size = COLOR_SIZE * pow(2, bit_depth)

		match clut:
			CLUT.NONE:
				pal_size = 0
			CLUT.HALF:
				pal_size /= 2
			_:
				pass

		id_hash = hash(bin_data.slice(ADDRESS_HEADER_END + pal_size, bin_data.size()))

	# The rest
	else:
		stream.seek(ADDRESS_CLUT)

		match bin_mode:
			MODE_RAW:
				mode = Mode.RAW
			MODE_ACPR:
				mode = Mode.ACPR
			MODE_PALETTE:
				mode = Mode.PALETTE
			MODE_5:
				mode = Mode.MODE_5
			_:
				push_error("BinSprite::deserialize() error! Invalid mode")
				return

		match stream.get_u16():
			CLUT_NONE:
				clut = CLUT.NONE
			CLUT_HALF:
				clut = CLUT.HALF
			CLUT_FULL:
				clut = CLUT.FULL
			_:
				push_error("BinSprite::deserialize() error! Invalid CLUT value")
				return

		bit_depth = stream.get_u16()
		width = stream.get_u16()
		height = stream.get_u16()
		texture_width = stream.get_u16()
		texture_height = stream.get_u16()
		id_hash = stream.get_u16()

		pal_size = COLOR_SIZE * pow(2, bit_depth)

		match clut:
			CLUT.NONE:
				pal_size = 0
			CLUT.HALF:
				pal_size /= 2
			CLUT.FULL:
				pass

	var pointer: int = ADDRESS_HEADER_END + pal_size
	palette = bin_data.slice(ADDRESS_HEADER_END, pointer)

	var pixel_data: PackedByteArray = bin_data.slice(pointer, bin_data.size())

	match mode:
		Mode.PALETTE:
			pixels = []
		Mode.RAW:
			pixels = pixel_data
		Mode.ACPR:
			pixels = SpriteCompression.decompress_acpr(bin_data)
		Mode.MODE_5:
			pixels = SpriteCompression.decompress_mode5(pixel_data)
		Mode.GGXP:
			if ggxp_compressed:
				pixels = SpriteCompression.decompress_ggx(bin_data)
			else:
				pixels = pixel_data

	image = Image.create_from_data(width, height, IMAGE_MIPMAPS, IMAGE_FORMAT, pixels)
	texture = ImageTexture.create_from_image(image)


static func get_texture_size(dimension: int) -> int:
	var p2_dimension: int = min(nearest_po2(dimension), 512)
	var texture_size: int = 0
	
	while p2_dimension > 1:
		p2_dimension >>= 1
		texture_size += 1
	
	return texture_size


static func init_empty_palette() -> BinSprite:
	var data: PackedByteArray = [0]
	var new_image: Image = Image.create_from_data(
			IMAGE_EMPTY_W, IMAGE_EMPTY_H, IMAGE_MIPMAPS, IMAGE_FORMAT, data
	)
	var new_texture: ImageTexture = ImageTexture.create_from_image(new_image)
	
	var sprite: BinSprite = BinSprite.new()
	var new_palette: PackedByteArray = []
	new_palette.resize(CLUT_SIZE_8_FULL)
	new_palette.fill(0)
	
	sprite.mode = Mode.PALETTE
	sprite.clut = CLUT.FULL
	sprite.bit_depth = DEPTH_8
	sprite.width = 0
	sprite.height = 0
	sprite.texture_width = 0
	sprite.texture_height = 0
	sprite.hash = 0
	sprite.manual_hash = true
	sprite.palette = new_palette
	sprite.pixels = []
	sprite.image = new_image
	sprite.texture = new_texture
	
	return sprite


static func init_from_import_data(import_data: ImportData) -> BinSprite:
	var sprite: BinSprite = BinSprite.new()
	
	sprite.mode = Mode.ACPR
	
	match import_data.clut:
		CLUT_NONE:
			sprite.clut = CLUT.NONE
		CLUT_HALF:
			sprite.clut = CLUT.HALF
		_:
			sprite.clut = CLUT.FULL
	
	sprite.bit_depth = import_data.bit_depth
	sprite.width = import_data.width
	sprite.height = import_data.height
	sprite.texture_width = get_texture_size(sprite.width)
	sprite.texture_height = get_texture_size(sprite.height)
	sprite.id_hash = hash(import_data.pixels)
	sprite.manual_hash = false
	sprite.palette = import_data.palette
	sprite.pixels = import_data.pixels
	
	return sprite


static func load_from_file(path: String, with_palette: bool) -> BinSprite:
	var import_data: ImportData
	
	match path.get_extension().to_lower():
		"bin":
			return load_from_bin(path, with_palette)
		"png":
			import_data = ImageImporter.load_from_png(path, with_palette)
		"bmp":
			import_data = ImageImporter.load_from_bmp(path, with_palette)
		"raw":
			import_data = ImageImporter.load_from_raw(path)
		_:
			print("BinSprite::load_from_file() error! Invalid source format provided")
			return null
	
	return init_from_import_data(import_data)


static func load_from_bin(path: String, with_palette: bool) -> BinSprite:
	var bin_data: PackedByteArray = FileAccess.get_file_as_bytes(path)
	
	if FileAccess.get_open_error() != Error.OK:
		print("BinSprite::load_from_bin(%s, %s) error! %s" % [path, with_palette, FileAccess.get_open_error()])
		return null
	
	var sprite: BinSprite = BinSprite.new()
	sprite.deserialize(bin_data, false)
	
	if !with_palette:
		sprite.purge_palette()
	
	return sprite


func has_palette() -> bool:
	if clut == CLUT.NONE:
		return false
	
	return !palette.is_empty()


func get_color_count() -> int:
	match clut:
		CLUT.NONE:
			return 0
		CLUT.HALF:
			if bit_depth == 4:
				return COLOR_COUNT_4_HALF
			else:
				return COLOR_COUNT_8_HALF
		_:
			if bit_depth == 4:
				return COLOR_COUNT_4_FULL
			else:
				return COLOR_COUNT_8_FULL


func get_color(index: int) -> Color:
	if index >= get_color_count():
		return Color.TRANSPARENT
	else:
		return Color8(
			palette[COLOR_SIZE * index + 0],
			palette[COLOR_SIZE * index + 1],
			palette[COLOR_SIZE * index + 2],
			palette[COLOR_SIZE * index + 3],
		)


func set_color(index: int, r: int, g: int, b: int, a: int) -> void:
	if index >= get_color_count():
		return
	
	palette[COLOR_SIZE * index + 0] = r
	palette[COLOR_SIZE * index + 1] = g
	palette[COLOR_SIZE * index + 2] = b
	palette[COLOR_SIZE * index + 3] = a


func purge_palette() -> void:
	palette.clear()
	clut = CLUT.NONE


func palette_halve_alpha() -> void:
	for index: int in get_color_count():
		var a: int = COLOR_SIZE * index + 3
		
		if palette[a] == 0xFF:
			palette[a] = 0x80
		else:
			palette[a] /= 2


func palette_double_alpha() -> void:
	for index: int in get_color_count():
		var a: int = COLOR_SIZE * index + 3
		
		if palette[a] >= 0x80:
			palette[a] = 0xFF
		else:
			palette[a] *= 2


func palette_make_opaque() -> void:
	for index: int in get_color_count():
		palette[COLOR_SIZE * index + 3] = 0xFF


func get_pixel(x: int, y: int) -> int:
	x = clampi(x, 0, width - 1)
	y = clampi(y, 0, height - 1)
	
	return pixels[y * height + x]


func flip_h() -> void:
	image.flip_x()
	pixels = image.get_data()
	texture = ImageTexture.create_from_image(image)


func flip_v() -> void:
	image.flip_y()
	pixels = image.get_data()
	texture = ImageTexture.create_from_image(image)


func transform_index(index: int) -> int:
	if ((index / 8) + 2) % 4 == 0:
		return index - 8
	
	elif ((index / 8) + 3) % 4 == 0:
		return index + 8
	
	return index


func transform_index_array(array: PackedByteArray) -> PackedByteArray:
	var temp_array: PackedByteArray = []
	
	for pixel: int in array.size():
		temp_array.append(transform_index(array[pixel]))
	
	return temp_array


func transform_rgba_array(array: PackedByteArray) -> PackedByteArray:
	var temp_array: PackedByteArray = []
	temp_array.resize(array.size())
	var color_count: int = array.size() / COLOR_SIZE
	
	for index: int in color_count:
		var new_index: int = transform_index(index)
		temp_array[COLOR_SIZE * index + 0] = array[COLOR_SIZE * new_index + 0]
		temp_array[COLOR_SIZE * index + 1] = array[COLOR_SIZE * new_index + 1]
		temp_array[COLOR_SIZE * index + 2] = array[COLOR_SIZE * new_index + 2]
		temp_array[COLOR_SIZE * index + 3] = array[COLOR_SIZE * new_index + 3]
	
	return temp_array


func reindex_pixels() -> void:
	if bit_depth == DEPTH_4:
		return
	
	pixels = transform_index_array(pixels)


func reindex_palette() -> void:
	if bit_depth == DEPTH_4 || clut == CLUT.NONE:
		return
	
	palette = transform_rgba_array(palette)
