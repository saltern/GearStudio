class_name ScriptEdit extends Control

@warning_ignore_start("unused_signal")
signal action_loaded
signal action_set_damage
signal action_flags_updated
signal action_seek_to_frame
signal action_select_instruction
signal action_count_changed
signal action_force_select
signal cell_updated
signal cell_clear
signal inst_cell
signal inst_semitrans
signal inst_scale
signal inst_rotate
signal inst_draw_normal
signal inst_draw_reverse
signal inst_cell_jump
signal inst_visual
signal inst_end_action
@warning_ignore_restore("unused_signal")

enum FlagType {
	FLAGS,
	LVFLAG,
	FLAG2,
}

@export var anim_player: AnimationPlayer

var SI := ScriptInstructions
var session_id: int
var undo_redo := UndoRedo.new()

var obj_data: Dictionary
#var bin_script := BinScript.new()
var action_index: int = 0
var instruction_index: int = -1
var this_action: ScriptAction
var this_cell: Cell

var new_instruction_type: int = 0


func _enter_tree() -> void:
	undo_redo.max_steps = Settings.misc_max_undo
	#bin_script = obj_data.scripts
	#script_deserialize()


func _ready() -> void:
	GlobalSignals.save_scripts.connect(script_save)
	
	anim_player.add_animation_library("", AnimationLibrary.new())
	script_action_load(0)


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	
	if not event is InputEventKey:
		return
	
	if Input.is_action_just_pressed("redo"):
		undo_redo.redo()
	
	elif Input.is_action_just_pressed("undo"):
		undo_redo.undo()


func set_session_id(new_id: int) -> void:
	session_id = new_id


# Undo/Redo status shorthand
func status_register_action(action_text: String) -> void:
	undo_redo.add_do_method(Status.set_status.bind(action_text))
	undo_redo.add_undo_method(Status.set_status.bind(tr("ACTION_UNDO").format({
		"action": action_text
	})))


#region Script de/serialization
func get_play_data_length(bin_data: PackedByteArray) -> int:
	var cursor: int = 0x0
	
	# From plusr_scripts.txt
	if bin_data[0x01] < 0x81 and bin_data[0x01] > 0x02:
		if bin_data[0x01] == 0x05:
			cursor = 0x300
		else:
			cursor = 0x100
			
			if bin_data[0x50] & 0x01:
				cursor = 0x180
			
			if bin_data[0x50] & 0x02:
				cursor += 0x80
			
			if bin_data[0x50] & 0x04:
				cursor += 0x80
			
			if bin_data[0x50] & 0x08:
				cursor += 0x80
	
	else:
		cursor = 0x80
	
	# Isuka hack
	if bin_data[cursor] == 0xE5:
		cursor *= 2
	
	return cursor


#func script_deserialize() -> void:
	#var script_bytes: PackedByteArray = obj_data["scripts"]
	#var action_bytes: PackedByteArray
	#
	## Player objects...
	#if obj_data.has("palettes"):
		#@warning_ignore("confusable_local_declaration")
		#var cursor: int = get_play_data_length(script_bytes)
		#bin_script.variables = script_bytes.slice(0x0, cursor)
		#action_bytes = script_bytes.slice(cursor, script_bytes.size())
	#else:
		#bin_script.variables = PackedByteArray([])
		#action_bytes = script_bytes.duplicate()
	#
	#var cursor: int = 0x00
	#
	#while cursor < action_bytes.size():
		## Check if script over
		## (slice end index is exclusive)
		#if action_bytes.slice(cursor, cursor + 0x02) == PackedByteArray([
			#0xFD, 0x00
		#]):
			#break
		#
		## Get action header
		#var new_action := ScriptAction.new()
		#
		#new_action.flags = action_bytes.decode_u32(cursor)
		#cursor += 0x04
		#
		#new_action.lvflag = action_bytes.decode_u16(cursor)
		#cursor += 0x02
		#
		#new_action.damage = action_bytes.decode_u8(cursor)
		#cursor += 0x01
		#
		#new_action.flag2 = action_bytes.decode_u8(cursor)
		#cursor += 0x01
		#
		## Get action instructions
		#var action_over: bool = false
		#
		#while not action_over and cursor < action_bytes.size():
			#var inst_id := action_bytes.decode_u8(cursor)
			#var inst_size := ScriptInstructions.get_instruction_size(inst_id)
			#var inst_bytes := action_bytes.slice(cursor, cursor + inst_size)
			#
			#var instruction := ScriptInstructions.get_instruction_from_data(
				#inst_bytes)
			#
			#cursor += inst_size
			#
			#if inst_id == 0xFF:
				#action_over = true
		#
			#new_action.instructions.append(instruction)
		#
		#bin_script.actions.append(new_action)


func script_serialize() -> PackedByteArray:
	print_debug("Script serialization started")
	var bytes: PackedByteArray = []
	bytes.append_array(obj_data.scripts.variables)
	
	var cursor: int = bytes.size()
	
	for action in obj_data.scripts.actions:
		# Header
		bytes.resize(bytes.size() + 0x08)
		
		bytes.encode_u32(cursor, action.flags)
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


func script_save(for_session: int) -> void:
	if for_session != session_id:
		return
	
	obj_data["scripts"] = script_serialize()
	print_debug("Script serialization complete")
#endregion


func script_action_get(index: int) -> ScriptAction:
	return obj_data.scripts.actions[index]


func script_action_get_count() -> int:
	return obj_data.scripts.actions.size()


func script_action_load(index: int) -> void:
	action_index = index
	this_action = script_action_get(action_index)
	instruction_index = -1
	
	script_animation_load()
	script_animation_restart()
	
	action_loaded.emit()


func script_action_ensure_selected(index: int) -> void:
	if action_index != index:
		script_action_load(index)
		action_force_select.emit(index)


func script_action_delete() -> void:
	if obj_data.scripts.actions.size() < 2:
		Status.set_status("STATUS_SCRIPT_EDIT_CANNOT_DELETE_ALL_ACTIONS")
		return
	
	var action_text: String = tr("ACTION_SCRIPT_EDIT_DELETE_ACTION".format({
		"index": action_index
	}))
	
	undo_redo.create_action(action_text)
	
	undo_redo.add_do_method(script_action_delete_commit.bind(action_index))
	undo_redo.add_undo_method(
		script_action_insert_commit.bind(action_index, this_action)
	)
	
	undo_redo.add_do_method(script_action_load.bind(action_index))
	undo_redo.add_do_method(
		emit_signal.bind("action_force_select", action_index)
	)
	
	undo_redo.add_undo_method(script_action_load.bind(action_index))
	undo_redo.add_undo_method(
		emit_signal.bind("action_force_select", action_index)
	)
	
	status_register_action(action_text)
	undo_redo.commit_action()


func script_action_insert(at_offset: int) -> void:
	var at: int = action_index + at_offset
	
	var action_text: String = tr("ACTION_SCRIPT_EDIT_NEW_ACTION").format({
		"index": at
	})
	
	undo_redo.create_action(action_text)
	
	var new_action := ScriptAction.new()
	new_action.instructions.append(
		ScriptInstructions.get_instruction(255)
	)

	undo_redo.add_do_method(script_action_insert_commit.bind(at, new_action))
	undo_redo.add_do_method(script_action_load.bind(at))
	undo_redo.add_do_method(emit_signal.bind("action_force_select", at))
	
	undo_redo.add_undo_method(script_action_delete_commit.bind(at))
	undo_redo.add_undo_method(script_action_load.bind(action_index))
	undo_redo.add_undo_method(
		emit_signal.bind("action_force_select", action_index)
	)
	
	status_register_action(action_text)
	undo_redo.commit_action()


func script_action_delete_commit(at_index: int) -> void:
	obj_data.scripts.actions.remove_at(at_index)
	action_count_changed.emit()


func script_action_insert_commit(at_index: int, action: ScriptAction) -> void:
	obj_data.scripts.actions.insert(at_index, action)
	action_count_changed.emit()


func script_action_copy() -> void:
	Clipboard.script_action = this_action
	Status.set_status(tr("STATUS_SCRIPT_EDIT_ACTION_COPY").format({
		"index": action_index
	}))


func script_action_paste(at: int) -> void:
	var new_action: ScriptAction = Clipboard.get_script_action()
	
	if new_action == null:
		Status.set_status("STATUS_SCRIPT_EDIT_ACTION_CANNOT_PASTE")
		return
	
	var action_text: String = tr("ACTION_SCRIPT_EDIT_PASTE_ACTION").format({
		"index": max(0, at)
	})
	
	undo_redo.create_action(action_text)
	
	if at == 0:
		var old_action: ScriptAction = script_action_get(action_index)
		
		undo_redo.add_do_method(script_action_delete_commit.bind(action_index))
		undo_redo.add_do_method(
			script_action_insert_commit.bind(action_index, new_action)
		)
		undo_redo.add_do_method(
			emit_signal.bind("action_force_select", action_index)
		)
		
		undo_redo.add_undo_method(
			script_action_delete_commit.bind(action_index)
		)
		undo_redo.add_undo_method(
			script_action_insert_commit.bind(action_index, old_action)
		)
		undo_redo.add_undo_method(
			emit_signal.bind("action_force_select", action_index)
		)
	
	else:
		at = max(0, at)
		
		undo_redo.add_do_method(
			script_action_insert_commit.bind(action_index + at, new_action)
		)
		undo_redo.add_do_method(
			emit_signal.bind("action_force_select", action_index + at)
		)
		
		undo_redo.add_undo_method(
			script_action_delete_commit.bind(action_index + at)
		)
		undo_redo.add_undo_method(
			emit_signal.bind("action_force_select", action_index + at)
		)
	
	undo_redo.add_do_method(script_action_load.bind(action_index + at))
	undo_redo.add_undo_method(script_action_load.bind(action_index))
	
	status_register_action(action_text)
	undo_redo.commit_action()


func script_action_set_damage(value: int) -> void:
	var action_text: String = tr("ACTION_SCRIPT_EDIT_SET_DAMAGE").format({
		"index": action_index
	})
	
	undo_redo.create_action(action_text, UndoRedo.MERGE_ENDS)
	
	undo_redo.add_do_property(this_action, "damage", value)
	undo_redo.add_do_method(emit_signal.bind("action_set_damage", value))
	
	undo_redo.add_undo_property(this_action, "damage", this_action.damage)
	undo_redo.add_undo_method(
		emit_signal.bind("action_set_damage", this_action.damage)
	)
	
	status_register_action(action_text)
	
	undo_redo.commit_action()


func script_action_set_flag(
	flag_type: FlagType, flag: int, enabled: bool
) -> void:
	var action_text: String = tr("ACTION_SCRIPT_EDIT_SET_FLAG").format({
		"index": action_index
	})
	
	undo_redo.create_action(action_text)
	
	if enabled:
		match flag_type:
			FlagType.FLAGS:
				undo_redo.add_do_property(
					this_action, "flags", this_action.flags | 1 << flag)
			FlagType.LVFLAG:
				undo_redo.add_do_property(
					this_action, "lvflag", this_action.lvflag | 1 << flag)
			FlagType.FLAG2:
				undo_redo.add_do_property(
					this_action, "flag2", this_action.flag2 | 1 << flag)
				
	else:
		match flag_type:
			FlagType.FLAGS:
				undo_redo.add_do_property(
					this_action, "flags", this_action.flags & ~(1 << flag))
			FlagType.LVFLAG:
				undo_redo.add_do_property(
					this_action, "lvflag", this_action.lvflag & ~(1 << flag))
			FlagType.FLAG2:
				undo_redo.add_do_property(
					this_action, "flag2", this_action.flag2 & ~(1 << flag))
	
	match flag_type:
		FlagType.FLAGS:
			undo_redo.add_undo_property(this_action,"flags",this_action.flags)
		FlagType.LVFLAG:
			undo_redo.add_undo_property(this_action,"lvflag",this_action.lvflag)
		FlagType.FLAG2:
			undo_redo.add_undo_property(this_action,"flag2",this_action.flag2)
	
	undo_redo.add_do_method(emit_signal.bind("action_flags_updated"))
	undo_redo.add_undo_method(emit_signal.bind("action_flags_updated"))
	
	status_register_action(action_text)
	
	undo_redo.commit_action()


func script_animation_load() -> void:
	var anim := Animation.new()
	anim.length = 0.0
	
	# Instruction tracks
	var track_cells		:= anim.add_track(Animation.TYPE_METHOD)	# 0
	var track_semitrans := anim.add_track(Animation.TYPE_METHOD)	# 6
	var track_scale		:= anim.add_track(Animation.TYPE_METHOD)	# 7
	var track_scale_y	:= anim.add_track(Animation.TYPE_METHOD)	# 7
	var track_rotate	:= anim.add_track(Animation.TYPE_METHOD)	# 8
	var track_draw		:= anim.add_track(Animation.TYPE_METHOD)	# 16
	#var track_draw_rev	:= anim.add_track(Animation.TYPE_METHOD)	# 17
	var track_cell_jump	:= anim.add_track(Animation.TYPE_METHOD)	# 39
	var track_visual	:= anim.add_track(Animation.TYPE_METHOD)	# 69
	var track_end		:= anim.add_track(Animation.TYPE_METHOD)	# 255
	
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
	
	anim.track_insert_key(track_draw, 0.0, {
		"method": &"emit_signal",
		"args": [&"inst_draw_normal"]
	})
	
	anim.track_insert_key(track_visual, 0.0, {
		"method": &"emit_signal",
		"args": [&"inst_visual", 0, 1]
	})
	
	anim.track_insert_key(track_visual, 0.1, {
		"method": &"emit_signal",
		"args": [&"inst_visual", 3, 0]
	})
	
	var frame: int = 1
	var frame_offset: int = 0
	var cell_count: int = 0
	
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
				anim.track_insert_key(track_draw, frame, {
					"method": &"emit_signal",
					"args": [&"inst_draw_normal"]
				})
			
			SI.NAME_DRAW_REVERSE:
				anim.track_insert_key(track_draw, frame, {
					"method": &"emit_signal",
					"args": [&"inst_draw_reverse"]
				})
			
			SI.NAME_CELL_JUMP:
				var disabled: int = instruction.arguments[0].value
				var cell_begin_number: int = instruction.arguments[2].value
				
				if disabled:
					continue
				
				anim.track_insert_key(track_cell_jump, frame, {
					"method": &"emit_signal",
					"args": [&"inst_cell_jump", cell_begin_number]
				})
			
			SI.NAME_VISUAL:
				var visual_mode: int = instruction.arguments[0].value
				var visual_argument: int = instruction.arguments[1].value
				var visual_offset: float = 0.0
				
				if visual_mode == 1:
					visual_offset = -0.1
				
				anim.track_insert_key(track_visual, frame + visual_offset, {
					"method": &"emit_signal",
					"args": [&"inst_visual", visual_mode, visual_argument]
				})
			
			SI.NAME_END_ACTION:
				var end_mode: int = instruction.arguments[0].value
				
				anim.track_insert_key(track_end, frame, {
					"method": &"emit_signal",
					"args": [&"inst_end_action", end_mode]
				})
	
	# Restart animation
	if cell_count == 0:
		cell_clear.emit()
	
	var library := anim_player.get_animation_library("")
	library.add_animation(&"anim", anim)


func script_animation_restart() -> void:
	anim_player.play(&"anim")
	anim_player.seek(0, true)
	script_animation_load_frame(1)


func script_animation_load_frame(frame: int) -> void:
	var time = anim_player.current_animation_position
	
	if frame > time:
		anim_player.advance(frame - time)
	else:
		# Likely slower, but required by instructions using additive operations
		anim_player.seek(0, true)
		anim_player.advance(frame)

	action_seek_to_frame.emit(frame)


func script_animation_get_length() -> int:
	return anim_player.current_animation_length


func script_animation_get_current_frame() -> int:
	return int(anim_player.current_animation_position)


func script_instruction_get(index: int) -> Instruction:
	return this_action.instructions[index]


func script_instruction_get_frame(index: int) -> int:
	var frame: int = 1
	var frame_offset: int = 0
	
	for number in range(0, index + 1):
		var instruction: Instruction = this_action.instructions[number]
		if instruction.id == 0:
			frame += frame_offset
			frame_offset = instruction.arguments[0].value
	
	return frame


func script_instruction_get_cell_frame(index: int) -> int:
	var frame: int = 1
	var frame_offset: int = 0
	var cell_begin_index: int = 0
	var inst_index: int = 0
	
	while cell_begin_index < index + 1:
		var instruction := this_action.instructions[inst_index]
		if instruction.id == 0:
			frame += frame_offset
			frame_offset = instruction.arguments[0].value
			cell_begin_index += 1
		
		inst_index += 1
		
		if inst_index >= this_action.instructions.size():
			break
	
	return frame


func script_instruction_select(index: int) -> void:
	instruction_index = index
	var instruction_frame: int = script_instruction_get_frame(instruction_index)
	script_animation_load_frame(instruction_frame)
	action_select_instruction.emit(instruction_index)
	#action_seek_to_frame.emit(instruction_frame)


func script_instruction_delete() -> void:
	if instruction_index < 0:
		return
	
	var action_text: String = tr("ACTION_SCRIPT_EDIT_DELETE_INSTRUCTION").format({
		"index": action_index
	})
	
	undo_redo.create_action(action_text)
	
	undo_redo.add_do_method(
		script_instruction_delete_commit.bind(instruction_index)
	)
	undo_redo.add_do_method(script_action_load.bind(action_index))
	undo_redo.add_do_method(
		script_animation_load_frame.bind(script_animation_get_current_frame())
	)
	
	undo_redo.add_undo_method(
		script_instruction_insert_commit.bind(
			instruction_index,
			script_instruction_get(instruction_index)
		)
	)
	undo_redo.add_undo_method(script_action_load.bind(action_index))
	undo_redo.add_undo_method(
		script_animation_load_frame.bind(script_animation_get_current_frame())
	)
	
	status_register_action(action_text)
	
	undo_redo.commit_action()


func script_instruction_delete_commit(at_index: int) -> void:
	this_action.instructions.remove_at(at_index)


func script_instruction_insert(at_index: int, instruction: Instruction) -> void:
	if at_index == -1:
		at_index = 0
	
	var action_text: String = tr("ACTION_SCRIPT_EDIT_INSERT_INSTRUCTION").format({
		"index": action_index
	})
	
	undo_redo.create_action(action_text)
	
	undo_redo.add_do_method(
		script_instruction_insert_commit.bind(at_index, instruction)
	)
	undo_redo.add_do_method(script_action_load.bind(action_index))
	undo_redo.add_do_method(script_instruction_select.bind(at_index))
	
	undo_redo.add_undo_method(script_instruction_delete_commit.bind(at_index))
	undo_redo.add_undo_method(script_action_load.bind(action_index))
	undo_redo.add_undo_method(script_instruction_select.bind(instruction_index))
	
	status_register_action(action_text)
	
	undo_redo.commit_action()


func script_instruction_insert_commit(
	at_index: int, instruction: Instruction
) -> void:
	this_action.instructions.insert(at_index, instruction)


func script_instruction_copy() -> void:
	if instruction_index < 0:
		Status.set_status("STATUS_SCRIPT_EDIT_INSTRUCTION_CANNOT_COPY")
		return
	
	var new_instruction := Instruction.new()
	var ref_instruction := script_instruction_get(instruction_index)
	new_instruction.id = ref_instruction.id
	new_instruction.display_name = ref_instruction.display_name
	
	for argument in ref_instruction.arguments:
		var new_argument := InstructionArgument.new()
		new_argument.display_name = argument.display_name
		new_argument.signed = argument.signed
		new_argument.value = argument.value
		new_argument.size = argument.size
		new_instruction.arguments.append(new_argument)
	
	Clipboard.instruction = new_instruction


func script_instruction_paste(at: int) -> void:
	var instruction: Instruction = Clipboard.get_instruction()
	
	if instruction == null:
		Status.set_status("STATUS_SCRIPT_EDIT_INSTRUCTION_CANNOT_PASTE")
		return
	
	var action_text: String = tr("ACTION_SCRIPT_EDIT_PASTE_INSTRUCTION").format({
		"index": action_index
	})
	
	undo_redo.create_action(action_text)
	
	# Replacement
	if at == 0:
		var old_instruction = script_instruction_get(instruction_index)
		
		undo_redo.add_do_method(
			script_instruction_delete_commit.bind(instruction_index)
		)
		undo_redo.add_do_method(
			script_instruction_insert_commit.bind(
				instruction_index, instruction
			)
		)
		
		undo_redo.add_undo_method(
			script_instruction_delete_commit.bind(instruction_index)
		)
		undo_redo.add_undo_method(
			script_instruction_insert_commit.bind(
				instruction_index, old_instruction
			)
		)
	
	# Insertion
	else:
		# -1 insertion would put new instructions at the back
		at = max(0, at)
		
		undo_redo.add_do_method(
			script_instruction_insert_commit.bind(
				instruction_index + at, instruction
			)
		)
	
		undo_redo.add_undo_method(
			script_instruction_delete_commit.bind(instruction_index + at)
		)
	
	undo_redo.add_do_method(script_action_load.bind(action_index))
	undo_redo.add_do_method(
		script_instruction_select.bind(instruction_index + at)
	)
	
	undo_redo.add_undo_method(script_action_load.bind(action_index))
	undo_redo.add_undo_method(script_instruction_select.bind(instruction_index))
	
	status_register_action(action_text)
	undo_redo.commit_action()


func script_instruction_move(direction: int) -> void:
	if instruction_index == -1:
		Status.set_status("STATUS_SCRIPT_EDIT_INSTRUCTION_MOVE_NOTHING")
		return
	
	var inst: Instruction = this_action.instructions[instruction_index]
	var from: int = instruction_index
	var to: int = 0
	
	match direction:
		0:	# Up
			to = max(0, instruction_index - 1)
		
		1:	# Down
			to = min(instruction_index + 1, this_action.instructions.size() - 1)
	
	if from == to:
		Status.set_status("STATUS_SCRIPT_EDIT_INSTRUCTION_CANNOT_MOVE")
		return
	
	var action_text: String = tr("ACTION_SCRIPT_EDIT_MOVE_INSTRUCTION").format({
		"index": action_index
	})
	undo_redo.create_action(action_text)
	
	undo_redo.add_do_method(script_action_ensure_selected.bind(action_index))
	undo_redo.add_do_method(script_instruction_delete_commit.bind(from))
	undo_redo.add_do_method(script_instruction_insert_commit.bind(to, inst))
	undo_redo.add_do_method(script_action_load.bind(action_index))
	undo_redo.add_do_method(script_instruction_select.bind(to))
	
	undo_redo.add_undo_method(script_action_ensure_selected.bind(action_index))
	undo_redo.add_undo_method(script_instruction_delete_commit.bind(to))
	undo_redo.add_undo_method(script_instruction_insert_commit.bind(from, inst))
	undo_redo.add_undo_method(script_action_load.bind(action_index))
	undo_redo.add_undo_method(script_instruction_select.bind(from))
	
	status_register_action(action_text)
	undo_redo.commit_action()


func script_argument_set(instruction: int, argument: int, value: int) -> void:
	var action_text: String = tr("ACTION_SCRIPT_EDIT_SET_ARGUMENT").format({
		"index": action_index, "instruction": instruction, "argument": argument
	})
	
	undo_redo.create_action(action_text, UndoRedo.MERGE_ENDS)
	
	var this_instruction := this_action.instructions[instruction]
	var this_argument := this_instruction.arguments[argument]
	
	undo_redo.add_do_property(this_argument, "value", value)
	undo_redo.add_undo_property(this_argument, "value", this_argument.value)
	
	var frame: int = script_animation_get_current_frame()
	
	undo_redo.add_do_method(script_action_load.bind(action_index))
	undo_redo.add_do_method(script_animation_load_frame.bind(frame))
	
	undo_redo.add_undo_method(script_action_load.bind(action_index))
	undo_redo.add_undo_method(script_instruction_select.bind(instruction))
	
	status_register_action(action_text)
	
	undo_redo.commit_action()


func sprite_get(index: int) -> BinSprite:
	if index < sprite_get_count():
		return obj_data["sprites"][index]
	else:
		return BinSprite.new()


func sprite_get_count() -> int:
	if obj_data.has("sprites"):
		return obj_data["sprites"].size()
	
	return 0


func sprite_get_index() -> int:
	return this_cell.sprite_info.index


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
