extends Button

enum PasteMode {
	BEFORE = -1,
	REPLACE,
	AFTER,
}

@export var paste_mode: PasteMode = PasteMode.REPLACE

@onready var script_edit: ScriptEdit = owner


func _ready() -> void:
	pressed.connect(script_edit.script_instruction_paste.bind(paste_mode))
