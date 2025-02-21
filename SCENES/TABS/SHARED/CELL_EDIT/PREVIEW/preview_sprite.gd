extends CellSpriteDisplay

@onready var cell_edit: CellEdit = get_owner()


func _ready() -> void:
	provider = cell_edit
	
	cell_edit.cell_updated.connect(load_cell)
	cell_edit.box_updated.connect(on_box_update)
	
	if provider.obj_data.has("palettes"):
		SessionData.palette_changed.connect(palette_set_session)
	
	else:
		SessionData.palette_changed.connect(palette_set_session_sprite)


func on_box_update(_box: BoxInfo) -> void:
	load_cell(cell_edit.this_cell)


func palette_set_session(for_session: int, index: int) -> void:
	if for_session != cell_edit.session_id:
		return
	
	load_palette(index)


func palette_set_session_sprite(for_session: int, _index: int) -> void:
	if for_session != cell_edit.session_id:
		return
	
	reload_palette()
