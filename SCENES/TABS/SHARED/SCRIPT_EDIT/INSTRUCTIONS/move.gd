extends Button

enum Direction {
	UP,
	DOWN,
}

@export var direction: Direction

@onready var script_edit: ScriptEdit = owner


func _ready() -> void:
	pressed.connect(script_edit.script_instruction_move.bind(direction))
