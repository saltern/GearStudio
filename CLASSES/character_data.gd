class_name CharacterData extends Resource

var palettes: Array[BinPalette] = []
var sprites: Array[BinSprite] = []
var cells: Array[Cell] = []


func load_palettes_from_path(path: String) -> bool:
	var dir: DirAccess = DirAccess.open(path)
	
	if not dir.dir_exists(path):
		return false
	
	# Load palettes
	for file in FileSort.get_sorted_files(path, "bin"):
		palettes.append(BinPalette.from_file(file))
	
	return true


func load_sprites_from_path(path: String) -> bool:
	var dir: DirAccess = DirAccess.open(path)
	
	if dir.get_open_error() != OK:
		return false
	
	# Load sprites
	sprites = SpriteLoader.load_sprites(path)

	return true


func load_cells_from_path(path: String) -> bool:
	var dir: DirAccess = DirAccess.open(path)
	
	if dir.get_open_error() != OK:
		return false
	
	# Load cells
	for file in FileSort.get_sorted_files(path, "json"):
		cells.append(Cell.from_file(file))
	
	return true


func get_boxes() -> Array[BoxInfo]:
	return cells[SharedData.cell_index].boxes
