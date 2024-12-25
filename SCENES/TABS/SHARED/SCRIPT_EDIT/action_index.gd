extends SteppingSpinBox

@onready var script_edit: ScriptEdit = owner


func _ready() -> void:
	max_value = script_edit.bin_script.actions.size() - 1
	value_changed.connect(load_action)


func load_action(index: int) -> void:
	script_edit.script_load_animation(index)
