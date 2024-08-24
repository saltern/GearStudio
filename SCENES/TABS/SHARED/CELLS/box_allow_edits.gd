extends CheckButton


func _ready() -> void:
	toggled.connect(toggle)


func toggle(new_value: bool) -> void:
	for node in get_tree().get_nodes_in_group("box_editors"):
		node.editable = new_value
	
	SharedData.box_edits_allowed = new_value
	
	if not SharedData.box_edits_allowed:
		SharedData.deselect_boxes()

	SharedData.box_editing_toggled.emit()
