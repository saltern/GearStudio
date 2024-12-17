class_name ScriptEdit extends MarginContainer

signal cell_loaded

var obj_data: Dictionary
var this_cell: Cell


func _enter_tree() -> void:
	obj_data = SessionData.object_data_get(get_parent().get_index())


func sprite_get_count() -> int:
	if obj_data.has("sprites"):
		return obj_data["sprites"].size()
	
	return 0


func sprite_get_index() -> int:
	return this_cell.sprite_info.index


func sprite_get(index: int) -> BinSprite:
	if index < sprite_get_count():
		return obj_data["sprites"][index]
	else:
		return BinSprite.new()


func palette_get_count() -> int:
	if obj_data.has("palettes"):
		return obj_data["palettes"].size()
	else:
		return 0


func palette_get(index: int) -> BinPalette:
	if index < palette_get_count():
		return obj_data["palettes"][index]
	else:
		return BinPalette.new()
