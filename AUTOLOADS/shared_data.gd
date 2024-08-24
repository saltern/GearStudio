# SharedData autoload
extends Node

signal changed_palette
signal deselected_boxes
signal selected_box
signal box_editing_toggled

var current_tab: int = 0

var data: CharacterData

var palette_index: int = 0
var cell_index: int = 0
var box_index: int = 0

var this_palette: BinPalette
var this_cell: Cell
var this_box: BoxInfo
var box_edits_allowed: bool = false


func get_palette(number: int = 0) -> BinPalette:
	palette_index = number
	this_palette = data.palettes[palette_index]
	changed_palette.emit()
	return this_palette


func get_cell(cell: int = 0) -> Cell:
	cell_index = cell
	box_index = 0
	this_cell = data.cells[cell_index]
	this_box = BoxInfo.new()
	
	return this_cell


func get_box(index: int = 0) -> BoxInfo:
	box_index = index
	return data.cells[cell_index].boxes[box_index]


func select_box(index: int = 0) -> void:
	get_box(index)
	selected_box.emit(index)


func deselect_boxes() -> void:
	box_index = -1
	deselected_boxes.emit()
