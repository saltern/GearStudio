extends Button

@onready var cell_edit: CellEdit = owner


func _ready() -> void:
	pressed.connect(cell_edit.cell_copy)
