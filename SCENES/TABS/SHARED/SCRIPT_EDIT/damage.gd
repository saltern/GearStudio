extends SteppingSpinBox

@onready var script_edit: ScriptEdit = owner


func _ready() -> void:
	script_edit.action_loaded.connect(update)
	script_edit.action_set_damage.connect(update.unbind(1))
	value_changed.connect(script_edit.script_action_set_damage)


func update() -> void:
	var action: ScriptAction = script_edit.this_action
	set_value_no_signal(action.damage)
