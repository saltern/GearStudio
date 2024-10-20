extends Button

@export_range(-1, 1, 1) var at: int = 0

@onready var cell_edit: CellEdit = owner


func _ready() -> void:
	pressed.connect(cell_edit.cell_paste.bind(at))
