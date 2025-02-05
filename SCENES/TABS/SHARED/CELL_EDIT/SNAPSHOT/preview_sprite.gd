extends CellSpriteDisplay

@export var cell_index: SteppingSpinBox

@onready var cell_edit: CellEdit = owner


func _ready() -> void:
	obj_data = cell_edit.obj_data
	
	cell_index.value_changed.connect(on_cell_changed)
	
	if obj_data.has("palettes"):
		SessionData.palette_changed.connect(palette_set_session)
	
	else:
		SessionData.palette_changed.connect(palette_set_session_sprite)
	
	load_cell(obj_data["cells"][0])


func on_cell_changed(index: int) -> void:
	load_cell(cell_edit.cell_get(index))


func palette_set_session(for_session: int, index: int) -> void:
	if for_session != cell_edit.session_id:
		return
	
	load_palette(index)


func palette_set_session_sprite(for_session: int, _index: int) -> void:
	if for_session != cell_edit.session_id:
		return
	
	reload_palette()
