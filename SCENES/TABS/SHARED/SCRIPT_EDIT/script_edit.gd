class_name ScriptEdit extends TabContainer

@warning_ignore_start("unused_signal")
signal action_loaded
signal action_set_damage
signal action_flags_updated
signal action_seek_to_frame
signal action_select_instruction
signal action_count_changed
signal action_force_select
signal cell_updated
@warning_ignore_restore("unused_signal")

enum FlagType {
	FLAGS,
	LVFLAG,
	FLAG2,
}

@export var var_editor: PackedScene
@export var chain_editor: PackedScene

@export var anim: ScriptAnimationPlayer
@export var anim_ref: ScriptAnimationPlayer

@export var cell_display: CellSpriteDisplay
@export var cell_display_ref: CellSpriteDisplay

@export var box_parent: Control
@export var box_parent_ref: Control

var SI := ScriptInstructions
var session_id: int
var undo_redo := UndoRedo.new()

var obj_data: Dictionary
var ref_handler: ReferenceHandler = ReferenceHandler.new()

var action_index: int = 0
var instruction_index: int = -1

var this_action: ScriptAction
var new_instruction_type: int = 0


func _enter_tree() -> void:
	undo_redo.max_steps = Settings.misc_max_undo
	
	cell_display.provider = self
	box_parent.provider = self
	anim.provider = self
	
	cell_display.anim = anim
	
	cell_display_ref.provider = ref_handler
	box_parent_ref.provider = ref_handler
	anim_ref.provider = ref_handler
	
	cell_display_ref.anim = anim_ref
	
	ref_handler.ref_action_index_set.connect(script_animation_load_ref.unbind(1))
	
	if obj_data.scripts.has_play_data:
		var index: int = 0
		for data_set: PlayData in obj_data.scripts.play_data:
			var new_var_editor: VariableEdit = var_editor.instantiate()
			new_var_editor.play_data = data_set
			new_var_editor.index = index
			add_child(new_var_editor)
			move_child(new_var_editor, 0 + index)
			index += 1
	
	SessionData.sprite_reindexed.connect(on_sprite_reindexed.unbind(1))


func _ready() -> void:
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


func script_action_get(index: int) -> ScriptAction:
	return obj_data.scripts.actions[index]


func script_action_get_count() -> int:
	return obj_data.scripts.actions.size()


func script_action_load(index: int) -> void:
	action_index = clampi(index, 0, script_action_get_count() - 1)
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
	
	var action_text: String = tr("ACTION_SCRIPT_EDIT_DELETE_ACTION").format({
		"index": action_index
	})
	
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
	anim.load_action(action_index)
	script_animation_load_ref()


func script_animation_load_ref() -> void:
	if ref_handler.action_index == -1:
		anim_ref.load_action(action_index)
	else:
		anim_ref.load_action(ref_handler.action_index)
	
	anim_ref.load_frame(script_animation_get_current_frame())


func script_animation_restart() -> void:
	anim.play(&"anim")
	anim.seek(0, true)
	
	if anim_ref.has_animation(&"anim"):
		anim_ref.play(&"anim")
		anim_ref.seek(0, true)
	
	anim.load_frame(1)
	anim_ref.load_frame(1)


func script_animation_get_length() -> int:
	return anim.current_animation_length


func script_animation_get_current_frame() -> int:
	return int(anim.current_animation_position)


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
	anim.load_frame(instruction_frame)
	anim_ref.load_frame(instruction_frame)
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
		#script_animation_load_frame.bind(script_animation_get_current_frame())
		anim.load_frame.bind(script_animation_get_current_frame())
	)
	
	undo_redo.add_undo_method(
		script_instruction_insert_commit.bind(
			instruction_index,
			script_instruction_get(instruction_index)
		)
	)
	undo_redo.add_undo_method(script_action_load.bind(action_index))
	undo_redo.add_undo_method(
		#script_animation_load_frame.bind(script_animation_get_current_frame())
		anim.load_frame.bind(script_animation_get_current_frame())
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
	
	for argument in ref_instruction.arguments:
		var new_argument := InstructionArgument.new()
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
			script_action_ensure_selected.bind(action_index))
		undo_redo.add_do_method(
			script_instruction_delete_commit.bind(instruction_index))
		undo_redo.add_do_method(script_instruction_insert_commit.bind(
			instruction_index, instruction))
		
		undo_redo.add_undo_method(
			script_action_ensure_selected.bind(action_index))
		undo_redo.add_undo_method(
			script_instruction_delete_commit.bind(instruction_index))
		undo_redo.add_undo_method(script_instruction_insert_commit.bind(
			instruction_index, old_instruction))
	
	# Insertion
	else:
		# -1 insertion would put new instructions at the back
		at = max(0, at)
		
		undo_redo.add_do_method(
			script_action_ensure_selected.bind(action_index))
		undo_redo.add_do_method(script_instruction_insert_commit.bind(
			instruction_index + at, instruction))
	
		undo_redo.add_undo_method(
			script_action_ensure_selected.bind(action_index))
		undo_redo.add_undo_method(
			script_instruction_delete_commit.bind(instruction_index + at))
	
	undo_redo.add_do_method(script_action_load.bind(action_index))
	undo_redo.add_do_method(
		script_instruction_select.bind(instruction_index + at))
	
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
	undo_redo.add_do_method(anim.load_frame.bind(frame))
	undo_redo.add_do_method(script_instruction_select.bind(instruction))
	#undo_redo.add_do_method(
		#emit_signal.bind("action_select_instruction", instruction))
	
	undo_redo.add_undo_method(script_action_load.bind(action_index))
	undo_redo.add_undo_method(script_instruction_select.bind(instruction))
	#undo_redo.add_undo_method(
		#emit_signal.bind("action_select_instruction", instruction))
	
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


func cell_get_count() -> int:
	if obj_data.has("cells"):
		return obj_data["cells"].size()
	else:
		return 0


func cell_get(index: int) -> Cell:
	if cell_get_count() > index:
		return obj_data.cells[index]
	else:
		return Cell.new()


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


#region Reference
#func reference_cell(index: int) -> void:
	#ref_handler.reference_cell_set(index)
#endregion


func on_sprite_reindexed(for_session: int) -> void:
	if for_session != session_id:
		return
	
	anim.load_frame(script_animation_get_current_frame())
