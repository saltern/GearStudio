extends Button

enum InsertMode {
	BEFORE = -1,
	REPLACE,
	AFTER,
}

@export var insert_mode: InsertMode

@onready var script_edit: ScriptEdit = owner


func _ready() -> void:
	pressed.connect(script_edit.script_action_paste.bind(insert_mode))
