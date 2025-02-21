extends CellSpriteDisplay

@onready var cell_edit: CellEdit = get_owner()


func _ready() -> void:
	provider = cell_edit
	
	cell_edit.ref_data_set.connect(on_ref_data_set)
	cell_edit.ref_data_cleared.connect(unload_sprite)
	cell_edit.ref_session_cleared.connect(unload_sprite)
	cell_edit.ref_cell_cleared.connect(unload_sprite)
	cell_edit.ref_cell_updated.connect(load_cell)
	cell_edit.ref_cell_index_set.connect(on_ref_cell_index_set)
	
	if provider.ref_data.has("palettes"):
		SessionData.palette_changed.connect(palette_set_session)
	
	else:
		SessionData.palette_changed.connect(palette_set_session_sprite)


func on_ref_data_set(data: Dictionary) -> void:
	var cell_index: int = cell_edit.cell_index
	
	if cell_edit.ref_cell_index > -1:
		cell_index = cell_edit.ref_cell_index
	
	load_cell(cell_edit.reference_cell_get(cell_index))


func on_ref_cell_index_set(index: int) -> void:
	if cell_edit.ref_data.is_empty():
		return
	
	if index < 0:
		index = cell_edit.cell_index
	
	load_cell(cell_edit.reference_cell_get(index))


func palette_set_session(for_session: int, index: int) -> void:
	if for_session != cell_edit.session_id:
		return
	
	load_palette(index)


func palette_set_session_sprite(for_session: int, _index: int) -> void:
	if for_session != cell_edit.session_id:
		return
	
	reload_palette()


# Override, obtain reference file palette instead of main file palette
func get_palette(index: int) -> PackedByteArray:
	# Global palette
	if provider.ref_data.has("palettes"):
		return provider.ref_data.palettes[palette_index].palette
	
	# Embedded palette
	var sprite: BinSprite = provider.ref_data.sprites[index]
	return sprite.palette
