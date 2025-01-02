extends SteppingSpinBox

@onready var script_edit: ScriptEdit = owner


func _ready() -> void:
	value_changed.connect(load_action)
	script_edit.action_count_changed.connect(update_max)
	script_edit.action_force_select.connect(on_external_select)
	update_max()


func load_action(index: int) -> void:
	script_edit.script_action_load(index)


func update_max() -> void:
	max_value = script_edit.script_action_get_count() - 1


func on_external_select(new_value: int) -> void:
	set_value_no_signal(new_value)
