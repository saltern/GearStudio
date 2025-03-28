class_name PlayData extends Resource

var unknown: int
var fwalk_vel: int
var bwalk_vel: int
var fdash_init_vel: int
var bdash_x_vel: int
var bdash_y_vel: int
var bdash_gravity: int
var fjump_x_vel: int
var bjump_x_vel: int
var jump_y_vel: int
var jump_gravity: int
var fsuperjump_x_vel: int
var bsuperjump_x_vel: int
var superjump_y_vel: int
var superjump_gravity: int
var fdash_accel: int
var fdash_reduce: int
var init_homingjump_y_vel: int
var init_homingjump_x_vel: int
var init_homingjump_x_reduce: int
var init_homingjump_y_offset: int
var airdash_minimum_height: int
var fairdash_time: int
var bairdash_time: int
var stun_res: int
var defense: int
var guts: int
var critical: int
var weight: int
var airdash_count: int
var airjump_count: int
var fairdash_no_attack_time: int
var bairdash_no_attack_time: int
var fwalk_tension: int
var fjump_tension: int
var fdash_tension: int
var fairdash_tension: int
var guardbalance_defense: int
var guardbalance_tension: int
var instantblock_tension: int


func from_dictionary(dict: Dictionary) -> void:
	unknown = dict["unk"]
	fwalk_vel = dict["fwalk_vel"]
	bwalk_vel = dict["bwalk_vel"]
	fdash_init_vel = dict["fdash_init_vel"]
	bdash_x_vel = dict["bdash_x_vel"]
	bdash_y_vel = dict["bdash_y_vel"]
	bdash_gravity = dict["bdash_gravity"]
	fjump_x_vel = dict["fjump_x_vel"]
	bjump_x_vel = dict["bjump_x_vel"]
	jump_y_vel = dict["jump_y_vel"]
	jump_gravity = dict["jump_gravity"]
	fsuperjump_x_vel = dict["fsuperjump_x_vel"]
	bsuperjump_x_vel = dict["bsuperjump_x_vel"]
	superjump_y_vel = dict["superjump_y_vel"]
	superjump_gravity = dict["superjump_gravity"]
	fdash_accel = dict["fdash_accel"]
	fdash_reduce = dict["fdash_reduce"]
	init_homingjump_x_vel = dict["init_homingjump_x_vel"]
	init_homingjump_y_vel = dict["init_homingjump_y_vel"]
	init_homingjump_x_reduce = dict["init_homingjump_x_reduce"]
	init_homingjump_y_offset = dict["init_homingjump_y_offset"]
	airdash_minimum_height = dict["airdash_minimum_height"]
	fairdash_time = dict["fairdash_time"]
	bairdash_time = dict["bairdash_time"]
	stun_res = dict["stun_res"]
	defense = dict["defense"]
	guts = dict["guts"]
	critical = dict["critical"]
	weight = dict["weight"]
	airdash_count = dict["airdash_count"]
	airjump_count = dict["airjump_count"]
	fairdash_no_attack_time = dict["fairdash_no_attack_time"]
	bairdash_no_attack_time = dict["bairdash_no_attack_time"]
	fwalk_tension = dict["fwalk_tension"]
	fjump_tension = dict["fjump_tension"]
	fdash_tension = dict["fdash_tension"]
	fairdash_tension = dict["fairdash_tension"]
	guardbalance_defense = dict["guardbalance_defense"]
	guardbalance_tension = dict["guardbalance_tension"]
	instantblock_tension = dict["instantblock_tension"]
