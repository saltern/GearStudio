class_name VariableEdit extends MarginContainer

@warning_ignore_start("unused_signal")
signal var_changed
signal table_entry_changed
@warning_ignore_restore("unused_signal")
signal chain_table_changed

var index: int = 0
var undo_redo: UndoRedo = UndoRedo.new()
var play_data: PlayData
var chain_table_index: int = 0


func _ready() -> void:
	undo_redo.max_steps = Settings.misc_max_undo
	Settings.language_changed.connect(update_title)
	update_title()
	
	visibility_changed.connect(register_action_history)


func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return
	
	if not event is InputEventKey:
		return
	
	if Input.is_action_just_pressed("redo"):
		redo()
	
	elif Input.is_action_just_pressed("undo"):
		undo()


#region Undo/Redo
func register_action_history() -> void:
	if not is_visible_in_tree():
		return
	
	ActionHistory.set_undo_redo(undo_redo)


func undo() -> void:
	if not is_visible_in_tree():
		return
	
	if not undo_redo.has_undo():
		Status.set_status("ACTION_NO_UNDO")
		return
	
	undo_redo.undo()


func redo() -> void:
	if not is_visible_in_tree():
		return
	
	if not undo_redo.has_redo():
		Status.set_status("ACTION_NO_REDO")
		return
	
	undo_redo.redo()
#endregion


func update_title() -> void:
	var base_name: String = tr("SCRIPT_EDIT_TITLE_PLAY_DATA")
	if index == 1:
		name = base_name + " (EX)"
	elif index > 0:
		name = base_name + " (%s)" % [index + 1]


# Undo/Redo status shorthand
func status_register_action(action_text: String) -> void:
	undo_redo.add_do_method(Status.set_status.bind(action_text))
	undo_redo.add_undo_method(Status.set_status.bind(tr("ACTION_UNDO").format({
		"action": action_text
	})))


func set_chain_table(table_index: int) -> void:
	chain_table_index = table_index
	chain_table_changed.emit()


func set_variable(var_name: String, new_value: int) -> void:
	var action_text: String = tr("ACTION_SCRIPT_EDIT_SET_VARIABLE").format({
		"variable": var_name
	})
	
	undo_redo.create_action(action_text, UndoRedo.MERGE_ENDS)
	
	undo_redo.add_do_method(play_data.variables.set.bind(var_name, new_value))
	undo_redo.add_do_method(
		emit_signal.bind("var_changed", var_name, new_value)
	)
	
	var old_value: int = play_data.variables.get(var_name)
	undo_redo.add_undo_method(play_data.variables.set.bind(var_name, old_value))
	undo_redo.add_undo_method(
		emit_signal.bind("var_changed", var_name, old_value)
	)

	status_register_action(action_text)
	undo_redo.commit_action()


func get_chain_table_bit(entry_name: String, bit: int) -> bool:
	var chain_table: ChainTable = play_data.chain_tables[chain_table_index]
	return (chain_table.get(entry_name) >> bit) & 1


func set_chain_table_bit(entry_name: String, bit: int, value: bool) -> void:
	var action_text: String = tr("ACTION_SCRIPT_EDIT_SET_CHAIN_BIT").format({
		"table": chain_table_index, "bit": bit
	})
	
	undo_redo.create_action(action_text, UndoRedo.MERGE_ENDS)
	
	var chain_table: ChainTable = play_data.chain_tables[chain_table_index]
	var old_flags: int = chain_table.get(entry_name)
	var new_flags: int = old_flags ^ (1 << bit)
	var old_value: bool = get_chain_table_bit(entry_name, bit)
	
	undo_redo.add_do_method(chain_table.set.bind(entry_name, new_flags))
	undo_redo.add_do_method(
		emit_signal.bind("table_entry_changed", entry_name, bit, value)
	)
	
	undo_redo.add_undo_method(chain_table.set.bind(entry_name, old_flags))
	undo_redo.add_undo_method(
		emit_signal.bind("table_entry_changed", entry_name, bit, old_value)
	)
	
	status_register_action(action_text)
	undo_redo.commit_action()
