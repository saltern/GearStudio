extends GridContainer

@onready var script_edit: ScriptEdit = owner


func _ready() -> void:
	script_edit.action_loaded.connect(update)
	
	for bit in range(32):
		var group: int = bit / 8
		var child: int = bit % 8
		var button: Button = get_child(group).get_child(child)
		
		button.toggled.connect(set_flag.bind(bit))


func update() -> void:
	var action: ScriptAction = script_edit.this_action
	var flags: int = action.flag
	
	for bit in range(32):
		var this_bit: int = (flags >> bit) & 1
		var group: int = bit / 8
		var child: int = bit % 8
		var button: Button = get_child(group).get_child(child)
		
		button.set_pressed_no_signal(bool(this_bit))


func set_flag(enabled: bool, bit: int) -> void:
	script_edit.script_action_set_flag(bit, enabled)
	update()
