extends TabContainer

@export var ObjTabSprites: PackedScene
@export var ObjTabCells: PackedScene

var data: CharacterData


func load_from_path(path: String) -> void:
	var dir: DirAccess = DirAccess.open(path)
	
	if dir.get_open_error() != OK:
		print("Could not load 'player' object!")
		return
	
	if dir.dir_exists("sprites"):
		data.sprites = SpriteLoader.load_sprites(path + "/sprites")
		
		var tab_sprites: Control = ObjTabSprites.instantiate()
		tab_sprites.data = data
		add_child(tab_sprites)
	
	if dir.dir_exists("cells"):
		# Load cells	
		for file in FileSort.get_sorted_files(path + "/cells", "json"):
			data.cells.append(Cell.from_file(file))
			
		var tab_cells: Control = ObjTabCells.instantiate()
		tab_cells.data = data
		add_child(tab_cells)
