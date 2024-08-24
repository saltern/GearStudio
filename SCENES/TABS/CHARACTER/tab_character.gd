extends VBoxContainer

@export var ObjTabPlayer: PackedScene
@export var ObjTabPalettes: PackedScene

@export var tab_container: TabContainer


func load_from_path(path: String) -> void:
	SharedData.data = CharacterData.new()
	
	var dir: DirAccess = DirAccess.open(path)
	
	if DirAccess.get_open_error() != OK:
		print("Could not load character!")
		return
	
	if SharedData.data.load_palettes_from_path(path + "/palettes"):
		tab_container.add_child(ObjTabPalettes.instantiate())
	
	if dir.dir_exists("player"):
		var _loaded_sprites: bool = \
			SharedData.data.load_sprites_from_path(path + "/player/sprites")
		
		var loaded_cells: bool = \
			SharedData.data.load_cells_from_path(path + "/player/cells")
		
		if loaded_cells:
			tab_container.add_child(ObjTabPlayer.instantiate())
