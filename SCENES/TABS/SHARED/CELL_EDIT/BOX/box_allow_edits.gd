extends CheckButton

@onready var cell_edit: CellEdit = get_owner()


func _ready() -> void:
	button_pressed = false
	cell_edit.box_set_editing(false)
	toggled.connect(cell_edit.box_set_editing)
