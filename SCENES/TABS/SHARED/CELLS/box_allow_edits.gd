extends CheckButton


func _ready() -> void:
	toggled.connect(toggle)


func toggle(new_value: bool) -> void:
	for node in get_tree().get_nodes_in_group("box_editors"):
		node.editable = new_value
