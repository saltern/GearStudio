extends HBoxContainer

@onready var cell_edit: CellEdit = get_owner()


func _ready() -> void:
	cell_edit.cell_updated.connect(on_cell_update)
	cell_edit.box_updated.connect(on_box_update)
	cell_edit.box_selected.connect(on_box_update)
	#cell_edit.box_deselected_all.connect(hide)


func on_cell_update(_cell: Cell) -> void:
	$value.editable = false


func on_box_update(box: BoxInfo) -> void:
	if box.type != 3 and box.type != 6:
		$value.editable = false
	else:
		$value.editable = true
