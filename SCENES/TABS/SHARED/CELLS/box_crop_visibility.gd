extends HBoxContainer


func _ready() -> void:
	var obj_state: ObjectEditState = SessionData.object_state_get(
			get_owner().get_parent().name)
	
	obj_state.cell_updated.connect(on_cell_update)
	obj_state.box_updated.connect(on_box_update)
	obj_state.box_selected.connect(on_box_update)
	obj_state.boxes_deselected.connect(hide)


func on_cell_update(_cell: Cell) -> void:
	hide()


func on_box_update(box: BoxInfo) -> void:
	if box.type != 3 and box.type != 6:
		hide()
	else:
		show()
