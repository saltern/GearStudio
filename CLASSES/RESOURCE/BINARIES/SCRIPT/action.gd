class_name Action extends BinObject

const HEADER_SIZE: int = 0x8

var flags: int		# u32
var lvflag: int		# u16
var damage: int		# u8
var flag2: int		# u8
var instructions: Array[Instruction]


func serialize() -> PackedByteArray:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.big_endian = big_endian
	
	stream.put_u32(flags)
	stream.put_u16(lvflag)
	stream.put_u8(damage)
	stream.put_u8(flag2)
	
	for instruction: Instruction in instructions:
		stream.put_data(instruction.serialize())
	
	return stream.data_array


func deserialize(bin_data: PackedByteArray, is_big_endian: bool) -> void:
	var stream: StreamPeerBuffer = StreamPeerBuffer.new()
	stream.data_array = bin_data
	stream.big_endian = is_big_endian
	big_endian = is_big_endian
	
	flags = stream.get_u32()
	lvflag = stream.get_u16()
	damage = stream.get_u8()
	flag2 = stream.get_u8()
	
	while stream.get_position() < bin_data.size():
		var id: int = stream.get_u8()
		var inst: Instruction = ScriptInstructions.get_instruction(id)
		
		for a: int in inst.arguments.size():
			if inst.arguments[a].signed:
				match inst.arguments[a].size:
					1:
						inst.set_argument(a, stream.get_8())
					2:
						inst.set_argument(a, stream.get_16())
					_:
						inst.set_argument(a, stream.get_32())
			else:
				match inst.arguments[a].size:
					1:
						inst.set_argument(a, stream.get_u8())
					2:
						inst.set_argument(a, stream.get_u16())
					_:
						inst.set_argument(a, stream.get_u32())
				
		instructions.append(inst)
		
		if id == 0xFF:
			break


static func from_data(
	p_flags: int, p_lvflag: int, p_damage: int, p_flag2: int,
	p_inst: Array[Instruction]
) -> Action:
	var action: Action = Action.new()
	action.flags = p_flags
	action.lvflag = p_lvflag
	action.damage = p_damage
	action.flag2 = p_flag2
	action.instructions = p_inst
	return action


func get_size() -> int:
	var size: int = HEADER_SIZE
	
	for instruction: Instruction in instructions:
		size += instruction.get_size()
	
	return size


func get_animation() -> Animation:
	var anim: Animation = Animation.new()
	anim.length = 0.00
	
	var track_cells			: int = anim.add_track(Animation.TYPE_METHOD)
	var track_semitrans		: int = anim.add_track(Animation.TYPE_METHOD)
	var track_scale			: int = anim.add_track(Animation.TYPE_METHOD)
	var track_scale_y		: int = anim.add_track(Animation.TYPE_METHOD)
	var track_rotate		: int = anim.add_track(Animation.TYPE_METHOD)
	var track_draw			: int = anim.add_track(Animation.TYPE_METHOD)
	var track_cell_jump		: int = anim.add_track(Animation.TYPE_METHOD)
	var track_palette		: int = anim.add_track(Animation.TYPE_METHOD)
	var track_visual		: int = anim.add_track(Animation.TYPE_METHOD)
	var track_end			: int = anim.add_track(Animation.TYPE_METHOD)
	
	for t: int in anim.get_track_count():
		anim.track_set_path(t, ".")
	
	# Resets
	anim.track_insert_key(track_semitrans, 0.0, {
		"method": "emit_signal",
		"args": ["inst_semitrans", 0, 0xFF]
	})
	
	anim.track_insert_key(track_scale, 0.00, {
		"method": "emit_signal",
		"args": ["inst_scale", 0, -1]
	})
	
	anim.track_insert_key(track_scale_y, 0.0, {
		"method": "emit_signal",
		"args": ["inst_scale", 1, -1]
	})
	
	anim.track_insert_key(track_rotate, 0.0, {
		"method": "emit_signal",
		"args": ["inst_rotate", 0, 0]
	})
	
	anim.track_insert_key(track_draw, 0.0, {
		"method": "emit_signal",
		"args": ["inst_draw_normal"]
	})
	
	anim.track_insert_key(track_palette, 0.0, {
		"method": "emit_signal",
		"args": ["inst_palette_clear"]
	})
	
	anim.track_insert_key(track_visual, 0.0, {
		"method": "emit_signal",
		"args": ["inst_visual", 0, 1]
	})
	
	anim.track_insert_key(track_visual, 0.1, {
		"method": "emit_signal",
		"args": ["inst_visual", 3, 0]
	})
	
	var frame: int = 1
	var frame_offset: int = 0
	
	for instruction: Instruction in instructions:
		# By ID
		match instruction.id:
			Instruction.ID_CELLBEGIN:
				frame += frame_offset
				var cell_length: int = max(1, instruction.get_argument(0))
				var cell_number: int = instruction.get_argument(1)
				var anim_length: int = anim.length
				
				anim.length = anim_length + cell_length
				anim.track_insert_key(track_cells, frame, {
					"method": "emit_signal",
					"args": ["inst_cell", cell_number]
				})
				
				frame_offset = cell_length
			
			Instruction.ID_SEMITRANS:
				var blend_value: int = instruction.get_argument(0)
				var blend_mode: int = instruction.get_argument(1)
				
				anim.track_insert_key(track_semitrans, frame, {
					"method": "emit_signal",
					"args": ["inst_semitrans", blend_mode, blend_value]
				})
			
			Instruction.ID_SCALE:
				var scale_mode: int = instruction.get_argument(0)
				var scale_value: int = instruction.get_argument(1)
				var which_track: int
				
				if scale_mode % 2 == 1:
					which_track = track_scale_y
				else:
					which_track = track_scale
				
				anim.track_insert_key(which_track, frame, {
					"method": "emit_signal",
					"args": ["inst_scale", scale_mode, scale_value]
				})
			
			Instruction.ID_ROT:
				var rotate_mode: int = instruction.get_argument(0)
				var rotate_value: int = instruction.get_argument(1)
				
				anim.track_insert_key(track_rotate, frame, {
					"method": "emit_signal",
					"args": ["inst_rotate", rotate_mode, rotate_value]
				})
			
			Instruction.ID_DRAW_NORMAL:
				anim.track_insert_key(track_draw, frame, {
					"method": "emit_signal",
					"args": ["inst_draw_normal"]
				})
			
			Instruction.ID_DRAW_REVERSE:
				anim.track_insert_key(track_draw, frame, {
					"method": "emit_signal",
					"args": ["inst_draw_reverse"]
				})
			
			Instruction.ID_CELL_JUMP:
				if instruction.get_argument(0) > 0:
					continue
				
				var cell_begin_number: int = instruction.get_argument(2)
				
				anim.track_insert_key(track_cell_jump, frame, {
					"method": "emit_signal",
					"args": ["inst_cell_jump", cell_begin_number]
				})
			
			Instruction.ID_PALETTE:
				var player: int = instruction.get_argument(0)
				var section: int = instruction.get_argument(1)
				
				anim.track_insert_key(track_palette, frame, {
					"method": "emit_signal",
					"args": ["inst_palette", player, section]
				})
			
			Instruction.ID_VISUAL:
				var visual_mode: int = instruction.get_argument(0)
				var visual_argument: int = instruction.get_argument(1)
				var visual_offset: float = 0.0
				
				if visual_mode == 1:
					visual_offset = -0.1
				
				anim.track_insert_key(track_visual, frame + visual_offset, {
					"method": "emit_signal",
					"args": ["inst_visual", visual_mode, visual_argument]
				})
			
			Instruction.ID_END_ACTION:
				var end_mode: int = instruction.get_argument(0)
				
				anim.track_insert_key(track_end, frame, {
					"method": "emit_signal",
					"args": ["inst_end_action", end_mode]
				})
	
	return anim
