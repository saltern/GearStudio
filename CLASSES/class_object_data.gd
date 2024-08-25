class_name ObjectData extends Resource

var sprites: Array[BinSprite] = []
var cells: Array[Cell] = []


func load_sprites_from_path(path: String) -> bool:
	if DirAccess.open(path) == null:
		return false
	
	# Load sprites
	sprites = SpriteLoader.load_sprites(path)

	return true


func load_cells_from_path(path: String) -> bool:
	if DirAccess.open(path) == null:
		return false
	
	# Load cells
	for file in FileSort.get_sorted_files(path, "json"):
		cells.append(Cell.from_file(file))
	
	return true


func get_boxes() -> Array[BoxInfo]:
	return cells[SessionData.get_cell_index()].boxes
