class_name ScriptEdit extends Control

signal action_loaded
signal cell_updated
signal cell_clear
signal inst_scale
signal inst_draw_normal
signal inst_draw_reverse

var SI: ScriptInstructions = ScriptInstructions
var session_id: int

var obj_data: Dictionary
var bin_script := BinScript.new()
var this_cell: Cell

var this_anim: Dictionary = {}


func _enter_tree() -> void:
	obj_data = SessionData.object_data_get(get_parent().get_index())
	deserialize_script()


func _ready() -> void:
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


# this_anim {
#	0: {
#		"CellBegin": 0,
#		"DrawReverse": 1,
#		"DrawNormal": 1,
#	},
#
#	1: ...


func script_load_animation(index: int) -> void:
	this_anim.clear()
	inst_draw_normal.emit()
	var scale_values: Array[int] = [1, 1000]
	inst_scale.emit(scale_values)
	
	var action = script_get_action(index)
	var frame: int = 1
	
	var frame_offset: int = 0
	
	for instruction: Instruction in action.instructions:
		var instruction_name: String = \
			SI.get_instruction_name(instruction.id)
		
		match instruction_name:
			SI.NAME_CELLBEGIN:
				frame += frame_offset
				
				if not this_anim.has(frame):
					this_anim[frame] = {}
				
				this_anim[frame][SI.NAME_CELLBEGIN] = \
					instruction.arguments[1].value
				frame_offset = instruction.arguments[0].value
			
			SI.NAME_SCALE:
				this_anim[frame][SI.NAME_SCALE] = [
					instruction.arguments[0].value,
					instruction.arguments[1].value
				]
			
			SI.NAME_DRAW_NORMAL:
				this_anim[frame][SI.NAME_DRAW_NORMAL] = 1
			
			SI.NAME_DRAW_REVERSE:
				this_anim[frame][SI.NAME_DRAW_REVERSE] = 1

	if this_anim.is_empty():
		cell_clear.emit()
		return
	
	script_load_frame(1)
	action_loaded.emit()


func script_load_frame(frame: int) -> void:
	if this_anim.is_empty():
		return
	
	var keys: PackedInt32Array = this_anim.keys()
	var index: int
	var cell: int
	
	if not keys.has(frame):
		index = keys.bsearch(frame)
		index = max(index - 1, 0)
	else:
		index = keys.find(frame)
	
	var this_frame: Dictionary = this_anim[keys[index]]
	
	if this_frame.has(SI.NAME_DRAW_NORMAL):
		inst_draw_normal.emit()
	
	if this_frame.has(SI.NAME_DRAW_REVERSE):
		inst_draw_reverse.emit()
	
	if this_frame.has(SI.NAME_SCALE):
		inst_scale.emit(this_frame[SI.NAME_SCALE])
	
	if not this_frame.has(SI.NAME_CELLBEGIN):
		return
	
	cell = this_anim[keys[index]][SI.NAME_CELLBEGIN]
	this_cell = obj_data["cells"][cell]
	cell_updated.emit(this_cell)


func script_get_action(index: int) -> ScriptAction:
	return bin_script.actions[index]


func script_action_get_frames(index: int) -> int:
	var action := script_get_action(index)
	var duration: int = 0
	
	for instruction in action.instructions:
		if instruction.id == 0:
			duration += instruction.arguments[0].value
	
	return duration


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
