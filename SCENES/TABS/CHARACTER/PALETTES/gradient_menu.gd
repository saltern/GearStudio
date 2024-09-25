extends PopupMenu


func display() -> void:
	position = get_tree().root.get_viewport().get_mouse_position()
	position += get_tree().root.get_window().position
	show()
