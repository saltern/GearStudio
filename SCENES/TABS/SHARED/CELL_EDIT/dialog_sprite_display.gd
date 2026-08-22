extends CellSpriteDisplay

@export var cell_index: SteppingSpinBox

var override_pal: PackedByteArray = []


func _ready() -> void:
	provider = owner
	
	var cell_edit: CellEdit = owner
	cell_index.value_changed.connect(cell_selected)
	cell_edit.cell_count_changed.connect(on_cell_count_changed)
	
	#if provider.obj_data.has("cells"):
	if provider.obj_data is BinScriptable:
		cell_selected(cell_index.value)


func cell_selected(index: int) -> void:
	load_cell(provider.obj_data.get_cell(index))


func on_cell_count_changed() -> void:
	cell_selected(cell_index.value)


func get_palette(index: int) -> PackedByteArray:
	if not override_pal.is_empty():
		return override_pal
	
	# Global palette
	#if provider.obj_data.has("palettes"):
	if provider.obj_data is BinScriptable and provider.obj_data.has_palettes():
		return provider.obj_data.get_palette_array(palette_index)
	
	# Embedded palette
	var sprite: BinSprite = provider.obj_data.get_sprite(index)
	return sprite.palette
