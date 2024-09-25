extends CheckButton

@export var editable_parent: Control

@onready var cell_edit: CellEdit = get_owner()


func _ready() -> void:
	button_pressed = false
	cell_edit.box_set_editing(false)
	#toggled.connect(cell_edit.box_set_editing)
	toggled.connect(on_edit_mode_toggle)


func on_edit_mode_toggle(enabled: bool) -> void:
	cell_edit.box_set_editing(enabled)
	editable_parent.visible = enabled
