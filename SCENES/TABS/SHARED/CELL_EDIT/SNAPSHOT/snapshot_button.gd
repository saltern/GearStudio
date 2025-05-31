extends Button

@export var multi_snap_dialog: Window

@onready var cell_edit: CellEdit = owner


func _pressed() -> void:
	if Input.is_key_pressed(KEY_SHIFT):
		multi_snap_dialog.show()
		return
	
	cell_edit.save_snapshot(cell_edit.cell_index, [])
