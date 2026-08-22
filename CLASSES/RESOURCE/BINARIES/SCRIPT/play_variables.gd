class_name PlayVariables extends BinObject

# u16, little endian (write as 0xE504)
const VARIABLE_NAMES		: PackedStringArray = [
	"walk_fwd_x_speed",		"walk_bwd_x_speed",			"dash_x_speed",
	"backdash_x_speed",		"backdash_y_speed",			"backdash_gravity",
	"jump_fwd_x_speed",		"jump_bwd_x_speed",			"jump_y_speed",
	"jump_gravity",			"sjump_fwd_x_speed",		"sjump_bwd_x_speed",
	"sjump_y_speed",		"sjump_gravity",			"dash_acceleration",
	"dash_resist",			"homing_jump_y_max",		"homing_jump_x_max",
	"homing_jump_x_resist", "homing_target_y_offset",	"airdash_height",
	"airdash_fwd_time",		"airdash_bwd_time",			"faint_point",
	"defense_point",		"guts",						"critical",
	"defense_gravity",		"airdash_count",			"jump_count",
	"airdash_fwd_atk_time",	"airdash_bwd_atk_time",		"tension_walk",
	"tension_jump",			"tension_dash",				"tension_airdash",
	"gc_gauge_def_point",	"gc_gauge_recovery",		"tension_ib",
]

var header					: int
# All are i16
var walk_fwd_x_speed		: int
var walk_bwd_x_speed		: int
var dash_x_speed			: int
var backdash_x_speed		: int
var backdash_y_speed		: int
var backdash_gravity		: int
var jump_fwd_x_speed		: int
var jump_bwd_x_speed		: int
var jump_y_speed			: int
var jump_gravity			: int
var sjump_fwd_x_speed		: int
var sjump_bwd_x_speed		: int
var sjump_y_speed			: int
var sjump_gravity			: int
var dash_acceleration		: int
var dash_resist				: int
var homing_jump_y_max		: int
var homing_jump_x_max		: int
var homing_jump_x_resist	: int
var homing_target_y_offset	: int
var airdash_height			: int
var airdash_fwd_time		: int
var airdash_bwd_time		: int
var faint_point				: int
var defense_point			: int
var guts					: int
var critical				: int
var defense_gravity			: int
var airdash_count			: int
var jump_count				: int
var airdash_fwd_atk_time	: int
var airdash_bwd_atk_time	: int
var tension_walk			: int
var tension_jump			: int
var tension_dash			: int
var tension_airdash			: int
var gc_gauge_def_point		: int
var gc_gauge_recovery		: int
var tension_ib				: int
var padding					: PackedByteArray


#static func identify(bin_data: PackedByteArray, is_big_endian: bool) -> bool:
	#var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	#stream.data_array = bin_data
	#stream.big_endian = is_big_endian
	#
	#var header: int = bin_data.decode_u16(0)
	#if header != HEADER:
		#return false
	#
	#if bin_data.size() < SIZE_U16 * VARIABLE_NAMES.size():
		#return false
	#
	#return true


func serialize() -> PackedByteArray:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.big_endian = big_endian
	
	stream.put_u16(header)
	
	for variable: String in VARIABLE_NAMES:
		stream.put_16(get(variable))
	
	stream.put_data(padding)
	
	return stream.data_array


func deserialize(bin_data: PackedByteArray, is_big_endian: bool) -> void:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.big_endian = is_big_endian
	big_endian = is_big_endian
	
	header = stream.get_u16()
	
	for variable in VARIABLE_NAMES:
		set(variable, stream.get_16())
	
	padding	= stream.get_data(bin_data.size() - stream.get_position())
