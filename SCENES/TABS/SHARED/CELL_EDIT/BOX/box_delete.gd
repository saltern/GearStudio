extends Button

@onready var cell_edit: CellEdit = get_owner()


func _ready() -> void:
	cell_edit.box_editing_toggled.connect(on_box_editing_toggled)
	pressed.connect(on_delete_pressed)
	disabled = true


func on_box_editing_toggled(enabled: bool) -> void:
	disabled = !enabled


func on_delete_pressed() -> void:
	cell_edit.box_delete()
