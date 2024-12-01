extends CellSpriteDisplay

@onready var cell_edit: CellEdit = get_owner()


func _ready() -> void:
	obj_data = cell_edit.obj_data
	
	cell_edit.cell_updated.connect(load_cell)
	cell_edit.box_updated.connect(on_box_update)
	#cell_edit.obj_data.palette_updated.connect(reload_palette)
	#cell_edit.obj_data.palette_selected.connect(load_palette)


func on_box_update(_box: BoxInfo) -> void:
	load_cell(cell_edit.this_cell)
