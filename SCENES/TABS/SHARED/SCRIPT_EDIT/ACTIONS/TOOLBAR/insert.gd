extends Button

enum InsertMode {
	BEFORE,
	AFTER,
}

@export var insert_mode: InsertMode

@onready var script_edit: ScriptEdit = owner


func _ready() -> void:
	pressed.connect(script_edit.script_action_insert.bind(insert_mode))
