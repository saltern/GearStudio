class_name ScriptEdit extends Control

signal action_loaded
signal cell_updated
signal cell_clear
signal inst_cell
signal inst_semitrans
signal inst_scale
signal inst_draw_normal
signal inst_draw_reverse

@export var anim_player: AnimationPlayer

var SI: ScriptInstructions = ScriptInstructions
var session_id: int

var obj_data: Dictionary
var bin_script := BinScript.new()
var this_cell: Cell


func _enter_tree() -> void:
	deserialize_script()


func _ready() -> void:
	anim_player.add_animation_library("", AnimationLibrary.new())
	script_load_animation(0)


func deserialize_script() -> void:
	var script_bytes: PackedByteArray = obj_data["scripts"]
	var action_bytes: PackedByteArray
	
	if script_bytes[0x100] != 0x00:
		bin_script.variables = script_bytes.slice(0x000, 0x300)
		action_bytes = script_bytes.slice(0x300, script_bytes.size())
	else:
		bin_script.variables = script_bytes.slice(0x000, 0x100)
		action_bytes = script_bytes.slice(0x100, script_bytes.size())
	
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


func script_load_animation(index: int) -> void:
	var anim := Animation.new()
	anim.length = 1.0
	
	# Instruction tracks
	var track_cells		:= anim.add_track(Animation.TYPE_METHOD)
	var track_semitrans := anim.add_track(Animation.TYPE_METHOD)
	var track_scale		:= anim.add_track(Animation.TYPE_METHOD)
	var track_draw_nor	:= anim.add_track(Animation.TYPE_METHOD)
	var track_draw_rev	:= anim.add_track(Animation.TYPE_METHOD)
	
	anim.track_set_path(track_cells, ".")
	anim.track_set_path(track_semitrans, ".")
	anim.track_set_path(track_scale, ".")
	anim.track_set_path(track_draw_nor, ".")
	anim.track_set_path(track_draw_rev, ".")
	
	# Resets
	anim.track_insert_key(track_semitrans, 0.0, {
		"method": &"emit_signal",
		"args": [&"inst_semitrans", 0, 0xFF]
	})
	
	anim.track_insert_key(track_scale, 0.0, {
		"method": &"emit_signal",
		"args": [&"inst_scale", 0, 1000]
	})
	
	anim.track_insert_key(track_draw_nor, 0.0, {
		"method": &"emit_signal",
		"args": [&"inst_draw_normal"]
	})
	
	var action = script_get_action(index)
	var frame: int = 1
	var frame_offset: int = 0
	var cell_count: int = 0
	
	for instruction: Instruction in action.instructions:
		var instruction_name: String = \
			SI.get_instruction_name(instruction.id)
		
		match instruction_name:
			SI.NAME_CELLBEGIN:
				cell_count += 1
				
				frame += frame_offset
				var cell_length: int = instruction.arguments[0].value
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
				
				anim.track_insert_key(track_scale, frame,{
					"method": &"emit_signal",
					"args": [&"inst_scale", scale_mode, scale_value]
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
		anim_player.seek(frame, true)


func script_get_animation_frames() -> int:
	return anim_player.current_animation_length


func script_get_action(index: int) -> ScriptAction:
	return bin_script.actions[index]


#func script_action_get_frames(index: int) -> int:
	#var action := script_get_action(index)
	#var duration: int = 0
	#
	#for instruction in action.instructions:
		#if instruction.id == 0:
			#duration += instruction.arguments[0].value
	#
	#return duration


func sprite_get_count() -> int:
	if obj_data.has("sprites"):
		return obj_data["sprites"].size()
	
	return 0


func sprite_get_index() -> int:
	return this_cell.sprite_info.index


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
