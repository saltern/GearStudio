extends Button

@export var from_sprite_spinbox: SteppingSpinBox
@export var to_sprite_spinbox: SteppingSpinBox

@onready var cell_edit: CellEdit = owner


func _pressed() -> void:
	var from: int = from_sprite_spinbox.value
	var to: int = to_sprite_spinbox.value
	
	var obj_data: Dictionary = cell_edit.obj_data

	for i: int in range(from, to, 1):
		var new_cell: Cell = Cell.new()
		var sprite: BinSprite = obj_data.sprites[i]
		
		new_cell.sprite_index = i
		new_cell.sprite_x_offset = 128 - sprite.width / 2
		new_cell.sprite_y_offset = 128 - sprite.height / 2
		
		obj_data.cells.append(new_cell)

	cell_edit.cell_count_changed.emit()
