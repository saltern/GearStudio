class_name ScriptEdit extends MarginContainer

signal cell_loaded

var obj_data: Dictionary
var this_cell: Cell


func _enter_tree() -> void:
	obj_data = SessionData.object_data_get(get_parent().get_index())


func sprite_get_index() -> int:
	return this_cell.sprite_info.index
