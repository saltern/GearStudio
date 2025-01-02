extends LineEdit

enum Type {
	X,
	Y,
}

@export var type: Type

@onready var cell_edit: CellEdit = owner


func _ready() -> void:
	cell_edit.cell_updated.connect(update)
	#text_changed.connect(filter_input)


func update(cell: Cell) -> void:
	match type:
		Type.X:
			text = "%s" % cell.sprite_x_offset
		Type.Y:
			text = "%s" % cell.sprite_y_offset


#func filter_input(new_text: String) -> void:
	#text = new_text.chr()
