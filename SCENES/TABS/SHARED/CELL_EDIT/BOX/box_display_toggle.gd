extends CheckButton

@onready var cell_edit: CellEdit = owner


func _toggled(toggled_on: bool) -> void:
	cell_edit.box_toggle_display(toggled_on)
