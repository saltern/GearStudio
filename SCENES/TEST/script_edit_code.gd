class_name ScriptEditCode extends Control

@export var cell_sprite_display: CellSpriteDisplay
@export var code_edit: BinScriptEdit

var session_id: int
var obj_data: Dictionary


func _ready() -> void:
	cell_sprite_display.obj_data = obj_data
	code_edit.inst_cell_begin.connect(code_edit_inst_cell_begin)


func set_session_id(new_id: int) -> void:
	session_id = new_id


func code_edit_inst_cell_begin(_duration: int, cell_index: int) -> void:
	if not obj_data.has("cells"):
		return
	
	var cell: Cell
	
	if obj_data.cells.size() > cell_index:
		cell = obj_data["cells"][cell_index]
	else:
		cell_sprite_display.unload_sprite()
		return
	
	cell_sprite_display.load_cell(cell)
