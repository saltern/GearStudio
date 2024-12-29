extends Control

@export var total_flags: int = 0
@export var flag_type: ScriptEdit.FlagType

@onready var script_edit: ScriptEdit = owner


func _ready() -> void:
	script_edit.action_loaded.connect(update)
	
	for bit in range(total_flags):
		var group: int = bit / 8
		var child: int = bit % 8
		var button: Button = get_child(group).get_child(child)
		
		button.toggled.connect(set_flag.bind(bit))


func update() -> void:
	var action: ScriptAction = script_edit.this_action
	var flags: int = 0
	
	match flag_type:
		ScriptEdit.FlagType.FLAGS:
			flags = action.flags
		ScriptEdit.FlagType.LVFLAG:
			flags = action.lvflag
		ScriptEdit.FlagType.FLAG2:
			flags = action.flag2
	
	for bit in range(total_flags):
		var this_bit: int = (flags >> bit) & 1
		var group: int = bit / 8
		var child: int = bit % 8
		var button: Button = get_child(group).get_child(child)
		
		button.set_pressed_no_signal(bool(this_bit))


func set_flag(enabled: bool, bit: int) -> void:
	script_edit.script_action_set_flag(flag_type, bit, enabled)
	update()
