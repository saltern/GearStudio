extends Button

@export var add_after: bool = false

@onready var cell_edit: CellEdit = owner


func _ready() -> void:
	pressed.connect(add_new_cell)


func add_new_cell() -> void:
	cell_edit.cell_new(add_after)
