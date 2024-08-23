extends VBoxContainer

@export var ObjTabPlayer: PackedScene
@export var ObjTabPalettes: PackedScene

@export var tab_container: TabContainer

var data: CharacterData


func load_from_path(path: String) -> void:
	data = CharacterData.new()
	
	var dir: DirAccess = DirAccess.open(path)
	
	if dir.get_open_error() != OK:
		print("Could not load character!")
		return

	if dir.dir_exists("palettes"):
		var tab_palettes: Control = ObjTabPalettes.instantiate()
		tab_palettes.data = data
		
		# Load palettes
		for file in FileSort.get_sorted_files(path + "/palettes", "bin"):
			data.palettes.append(BinPalette.from_file(file))
		
		tab_container.add_child(tab_palettes)
	
	if dir.dir_exists("player"):
		var tab_player: Control = ObjTabPlayer.instantiate()
		tab_player.data = data
		tab_player.load_from_path(path + "/player")
		tab_container.add_child(tab_player)
