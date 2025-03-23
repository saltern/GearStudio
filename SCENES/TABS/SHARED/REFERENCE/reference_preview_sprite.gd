extends CellSpriteDisplay

@onready var ref_handler: ReferenceHandler = owner.ref_handler


func _ready() -> void:
	provider = ref_handler
	
	ref_handler.ref_data_set.connect(on_ref_data_set)
	ref_handler.ref_data_cleared.connect(unload_sprite)
	ref_handler.ref_session_cleared.connect(unload_sprite)
	ref_handler.ref_cell_cleared.connect(unload_sprite)
	ref_handler.ref_cell_updated.connect(load_cell)
	ref_handler.ref_cell_index_set.connect(on_ref_cell_index_set)
	
	if ref_handler.obj_data.has("palettes"):
		SessionData.palette_changed.connect(palette_set_session)
	
	else:
		SessionData.palette_changed.connect(palette_set_session_sprite)


func on_ref_data_set(data: Dictionary) -> void:
	var cell_index: int = owner.cell_index
	
	if ref_handler.cell_index > -1:
		cell_index = ref_handler.cell_index
	
	load_cell(ref_handler.reference_cell_get(cell_index))


func on_ref_cell_index_set(index: int) -> void:
	if ref_handler.ref_data.is_empty():
		return
	
	if index < 0:
		index = owner.cell_index
	
	load_cell(ref_handler.reference_cell_get(index))


func palette_set_session(for_session: int, index: int) -> void:
	if for_session != owner.session_id:
		return
	
	load_palette(index)


func palette_set_session_sprite(for_session: int, _index: int) -> void:
	if for_session != owner.session_id:
		return
	
	reload_palette()


# Override, obtain reference file palette instead of main file palette
func get_palette(index: int) -> PackedByteArray:
	if ref_handler.obj_data.is_empty():
		return []
	
	# Global palette
	if ref_handler.obj_data.has("palettes"):
		return ref_handler.obj_data.palettes[palette_index].palette
	
	# Embedded palette
	var sprite: BinSprite = ref_handler.obj_data.sprites[index]
	return sprite.palette
