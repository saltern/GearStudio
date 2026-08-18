class_name ChainTable extends BinObject

const SIZE: int = 0x80

const CHAIN_NAMES: PackedStringArray = [
"chain_5p",		"chain_6p",		"chain_5k",
"chain_fs",		"chain_cs",		"chain_5h",
"chain_6h",		"chain_2p",		"chain_2k",
"chain_2d",		"chain_2s",		"chain_2h",
"chain_jp",		"chain_jk",		"chain_js",
"chain_jh",		"chain_unk16",	"chain_j2k",
"chain_3p",		"chain_unk19",	"chain_unk20",
"chain_6k",		"chain_j2s",	"chain_3s",
"chain_3k",		"chain_3h",		"chain_j2h",
"chain_unk27",	"chain_unk28",	"chain_unk29",
"chain_unk30",	"chain_unk31",
]

# All u32
var chain_5p		: int
var chain_6p		: int
var chain_5k		: int
var chain_fs		: int
var chain_cs		: int
var chain_5h		: int
var chain_6h		: int
var chain_2p		: int
var chain_2k		: int
var chain_2d		: int
var chain_2s		: int
var chain_2h		: int
var chain_jp		: int
var chain_jk		: int
var chain_js		: int
var chain_jh		: int
var chain_unk16		: int
var chain_j2k		: int
var chain_3p		: int
var chain_unk19		: int
var chain_unk20		: int
var chain_6k		: int
var chain_j2s		: int
var chain_3s		: int
var chain_3k		: int
var chain_3h		: int
var chain_j2h		: int
var chain_unk27		: int
var chain_unk28		: int
var chain_unk29		: int
var chain_unk30		: int
var chain_unk31		: int


func serialize() -> PackedByteArray:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.big_endian = big_endian
	
	for chain: String in CHAIN_NAMES:
		stream.put_u32(get(chain))
	
	return stream.data_array


func deserialize(bin_data: PackedByteArray, is_big_endian: bool) -> void:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.data_array = bin_data
	stream.big_endian = is_big_endian
	big_endian = is_big_endian
	
	for chain: String in CHAIN_NAMES:
		set(chain, stream.get_u32())
