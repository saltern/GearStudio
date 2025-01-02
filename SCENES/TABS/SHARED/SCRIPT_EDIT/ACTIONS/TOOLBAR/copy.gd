extends Button

@onready var script_edit: ScriptEdit = owner


func _ready() -> void:
	pressed.connect(script_edit.script_action_copy)
