extends HBoxContainer

@export var palette_grid: GridContainer
@export var preview: TextureRect


func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouse:
		return
	
	palette_grid.index_hovered = -1
	
	preview.material.set_shader_parameter("highlight_index", -1)
