extends CheckButton

@export var cell_sprite_display: CellSpriteDisplay

@onready var cell_edit: CellEdit = owner


func _toggled(toggled_on: bool) -> void:
	cell_sprite_display.visual_1 = toggled_on
	cell_sprite_display.load_cell(cell_edit.this_cell)
