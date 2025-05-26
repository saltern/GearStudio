extends PopupMenu

@export var grid: PaletteGrid


func _ready() -> void:
	index_pressed.connect(on_index_pressed)


func display() -> void:
	position = get_tree().root.get_viewport().get_mouse_position()
	position += get_tree().root.get_window().position
	show()


# Because the grid holds the selection data
func on_index_pressed(index: int) -> void:
	grid.apply_gradient(index)
