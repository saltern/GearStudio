class_name CharacterData extends Resource

var cells: Array[Cell] = []
var sprites: Array[BinSprite] = []
var palettes: Array[BinPalette] = []

var cell_index: int = 0


func get_boxes() -> Array[BoxInfo]:
	return cells[cell_index].boxes
