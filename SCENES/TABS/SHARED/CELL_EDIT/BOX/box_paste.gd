extends Button

@onready var cell_edit: CellEdit = owner


func _pressed() -> void:
	cell_edit.box_paste()
