extends TextureRect

@onready var cell_edit: CellEdit = owner


func _ready() -> void:
	cell_edit.cell_updated.connect(cell_loaded)
	cell_edit.box_deselected_all.connect(hide)
	cell_edit.box_selected.connect(select_check)


func cell_loaded(cell: BinCell) -> void:
	hide()
	#texture = cell_edit.obj_data["sprites"][cell.sprite_index].get_texture()
	texture = cell_edit.obj_data.get_sprite(cell.sprite_index).texture


func select_check(box: BinBoxInfo) -> void:
	if box.box_type == 3 or box.box_type == 6:
		show()
