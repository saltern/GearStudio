class_name ScriptEdit extends Control

signal action_loaded
signal cell_updated
signal cell_clear
signal inst_cell
signal inst_semitrans
signal inst_scale
signal inst_rotate
signal inst_draw_normal
signal inst_draw_reverse
signal inst_visual

@export var anim_player: AnimationPlayer

var SI: ScriptInstructions = ScriptInstructions
var session_id: int

var obj_data: Dictionary
var bin_script := BinScript.new()
var action_index: int = 0
var this_action: ScriptAction
var this_cell: Cell


func _enter_tree() -> void:
	deserialize_script()


func _ready() -> void:
	GlobalSignals.save_scripts.connect(script_save)
	
	anim_player.add_animation_library("", AnimationLibrary.new())
	script_load_action(0)


func deserialize_script() -> void:
	var script_bytes: PackedByteArray = obj_data["scripts"]
	var action_bytes: PackedByteArray
	
	if obj_data.has("palettes"):
		if script_bytes[0x100] != 0x00:
			bin_script.variables = script_bytes.slice(0x000, 0x300)
			action_bytes = script_bytes.slice(0x300, script_bytes.size())
		else:
			bin_script.variables = script_bytes.slice(0x000, 0x100)
			action_bytes = script_bytes.slice(0x100, script_bytes.size())
	else:
		bin_script.variables = PackedByteArray([])
		action_bytes = script_bytes.duplicate()
	
	var cursor: int = 0x00
	
	while cursor < action_bytes.size():
		# Check if script over
		# (slice end index is exclusive)
		if action_bytes.slice(cursor, cursor + 0x02) == PackedByteArray([
			0xFD, 0x00
		]):
			break
		
		# Get action header
		var new_action := ScriptAction.new()
		
		new_action.flag = action_bytes.decode_u32(cursor)
		cursor += 0x04
		
		new_action.lvflag = action_bytes.decode_u16(cursor)
		cursor += 0x02
		
		new_action.damage = action_bytes.decode_u8(cursor)
		cursor += 0x01
		
		new_action.flag2 = action_bytes.decode_u8(cursor)
		cursor += 0x01
		
		# Get action instructions
		var action_over: bool = false
		
		while not action_over and cursor < action_bytes.size():
			var inst_id := action_bytes.decode_u8(cursor)
			var inst_size := ScriptInstructions.get_instruction_size(inst_id)
			var inst_bytes := action_bytes.slice(cursor, cursor + inst_size)
			
			var instruction := ScriptInstructions.get_instruction_from_data(
				inst_bytes)
			
			cursor += inst_size
			
			if inst_id == 0xFF:
				action_over = true
		
			new_action.instructions.append(instruction)
		
		bin_script.actions.append(new_action)


func serialize_script() -> PackedByteArray:
	var bytes: PackedByteArray = []
	bytes.append_array(bin_script.variables)
	
	var cursor: int = bytes.size()
	
	for action in bin_script.actions:
		# Header
		bytes.resize(bytes.size() + 0x08)
		
		bytes.encode_u32(cursor, action.flag)
		cursor += 0x04
		
		bytes.encode_u16(cursor, action.lvflag)
		cursor += 0x02
		
		bytes.encode_u8(cursor, action.damage)
		cursor += 0x01
		
		bytes.encode_u8(cursor, action.flag2)
		cursor += 0x01
		
		# Instructions
		for instruction in action.instructions:
			# Instruction ID
			bytes.resize(bytes.size() + 0x01)
			bytes.encode_u8(cursor, instruction.id)
			cursor += 0x01
			
			for argument in instruction.arguments:
				bytes.resize(bytes.size() + argument.size)
				
				match argument.size:
					1:
						bytes.encode_u8(cursor, argument.value)
					2:
						bytes.encode_u16(cursor, argument.value)
					4:
						bytes.encode_u32(cursor, argument.value)
					8:
						bytes.encode_u64(cursor, argument.value)
				
				cursor += argument.size
	
	# End script
	bytes.append_array(PackedByteArray([0xFD, 0x00]))
	
	# Zero-pad
	bytes.resize(bytes.size() + bytes.size() % 0x10)
	
	return bytes


func script_load_action(index: int) -> void:
	var anim := Animation.new()
	anim.length = 0.0
	
	# Instruction tracks
	var track_cells		:= anim.add_track(Animation.TYPE_METHOD)	# 0
	var track_semitrans := anim.add_track(Animation.TYPE_METHOD)	# 6
	var track_scale		:= anim.add_track(Animation.TYPE_METHOD)	# 7
	var track_scale_y	:= anim.add_track(Animation.TYPE_METHOD)	# 7
	var track_rotate	:= anim.add_track(Animation.TYPE_METHOD)	# 8
	var track_draw_nor	:= anim.add_track(Animation.TYPE_METHOD)	# 16
	var track_draw_rev	:= anim.add_track(Animation.TYPE_METHOD)	# 17
	var track_visual	:= anim.add_track(Animation.TYPE_METHOD)	# 69
	
	for track in anim.get_track_count():
		anim.track_set_path(track, ".")
	
	# Resets
	anim.track_insert_key(track_semitrans, 0.0, {
		"method": &"emit_signal",
		"args": [&"inst_semitrans", 0, 0xFF]
	})
	
	anim.track_insert_key(track_scale, 0.0, {
		"method": &"emit_signal",
		"args": [&"inst_scale", 0, -1]
	})
	
	anim.track_insert_key(track_scale_y, 0.0, {
		"method": &"emit_signal",
		"args": [&"inst_scale", 1, -1]
	})
	
	anim.track_insert_key(track_rotate, 0.0, {
		"method": &"emit_signal",
		"args": [&"inst_rotate", 0, 0]
	})
	
	anim.track_insert_key(track_draw_nor, 0.0, {
		"method": &"emit_signal",
		"args": [&"inst_draw_normal"]
	})
	
	anim.track_insert_key(track_visual, 0.0, {
		"method": &"emit_signal",
		"args": [&"inst_visual", 0, 1]
	})
	
	action_index = index
	this_action = script_get_action(action_index)
	var frame: int = 1
	var frame_offset: int = 0
	var cell_count: int = 0
	var tied: bool = true
	
	for instruction: Instruction in this_action.instructions:
		var instruction_name: String = \
			SI.get_instruction_name(instruction.id)
		
		match instruction_name:
			SI.NAME_CELLBEGIN:
				cell_count += 1
				
				frame += frame_offset
				var cell_length: int = max(1, instruction.arguments[0].value)
				var cell_number: int = instruction.arguments[1].value
				
				anim.length += cell_length
				anim.track_insert_key(track_cells, frame, {
					"method": &"emit_signal",
					"args": [&"inst_cell", cell_number],
				})
				
				frame_offset = cell_length
			
			SI.NAME_SEMITRANS:
				var blend_mode: int = instruction.arguments[1].value
				var blend_value: int = instruction.arguments[0].value
				
				anim.track_insert_key(track_semitrans, frame, {
					"method": &"emit_signal",
					"args": [&"inst_semitrans", blend_mode, blend_value]
				})
			
			SI.NAME_SCALE:
				var scale_mode: int = instruction.arguments[0].value
				var scale_value: int = instruction.arguments[1].value
				var which_track: int = track_scale
				
				if scale_mode % 2 == 1:
					which_track = track_scale_y
				
				anim.track_insert_key(which_track, frame, {
					"method": &"emit_signal",
					"args": [&"inst_scale", scale_mode, scale_value]
				})
			
			SI.NAME_ROT:
				var rotate_mode: int = instruction.arguments[0].value
				var rotate_value: int = instruction.arguments[1].value
				
				anim.track_insert_key(track_rotate, frame, {
					"method": &"emit_signal",
					"args": [&"inst_rotate", rotate_mode, rotate_value]
				})
			
			SI.NAME_DRAW_NORMAL:
				anim.track_insert_key(track_draw_nor, frame, {
					"method": &"emit_signal",
					"args": [&"inst_draw_normal"]
				})
			
			SI.NAME_DRAW_REVERSE:
				anim.track_insert_key(track_draw_rev, frame, {
					"method": &"emit_signal",
					"args": [&"inst_draw_reverse"]
				})
			
			SI.NAME_VISUAL:
				#continue
				var visual_mode: int = instruction.arguments[0].value
				var visual_argument: int = instruction.arguments[1].value
				
				anim.track_insert_key(track_visual, frame, {
					"method": &"emit_signal",
					"args": [&"inst_visual", visual_mode, visual_argument]
				})
	
	# Restart animation
	if cell_count == 0:
		cell_clear.emit()
	
	var library := anim_player.get_animation_library("")
	library.add_animation(&"anim", anim)
	
	anim_player.play(&"anim")
	anim_player.seek(0, true)
	script_load_frame(1)
	
	action_loaded.emit()


func script_load_frame(frame: int) -> void:
	var time = anim_player.current_animation_position
	
	if frame > time:
		anim_player.advance(frame - time)
	else:
		# Likely slower, but required by instructions using additive operations
		anim_player.seek(0, true)
		anim_player.seek(frame, true)


func script_get_animation_frames() -> int:
	return anim_player.current_animation_length


func script_get_current_frame() -> int:
	return int(anim_player.current_animation_position)


func script_get_action(index: int) -> ScriptAction:
	return bin_script.actions[index]


func script_get_instruction(index: int) -> Instruction:
	return this_action.instructions[index]


func script_save(for_session: int) -> void:
	if for_session != session_id:
		return
	
	obj_data["scripts"] = serialize_script()


func sprite_get_count() -> int:
	if obj_data.has("sprites"):
		return obj_data["sprites"].size()
	
	return 0


func sprite_get_index() -> int:
	return this_cell.sprite_info.index


func script_action_set_flag(flag: int, enabled: bool) -> void:
	if enabled:
		this_action.flag |= 1 << flag
	else:
		this_action.flag &= ~(1 << flag)


func script_set_argument(instruction: int, argument: int, value: int) -> void:
	var this_instruction: Instruction = this_action.instructions[instruction]
	this_instruction.arguments[argument].value = value
	
	var frame: int = script_get_current_frame()
	
	script_load_action(action_index)
	script_load_frame(frame)


func sprite_get(index: int) -> BinSprite:
	if index < sprite_get_count():
		return obj_data["sprites"][index]
	else:
		return BinSprite.new()


func cell_get_count() -> int:
	if obj_data.has("cells"):
		return obj_data["cells"].size()
	else:
		return 0


func palette_get_count() -> int:
	if obj_data.has("palettes"):
		return obj_data["palettes"].size()
	else:
		return 0


func palette_get(index: int) -> BinPalette:
	if index < palette_get_count():
		return obj_data["palettes"][index]
	else:
		return BinPalette.new()
