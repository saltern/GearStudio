class_name ObjectData extends Resource

var sprites: Array[BinSprite] = []
var cells: Array[Cell] = []


func serialize_cells() -> Array[String]:
	var array: Array[String]
	
	for cell in cells:
		var this_cell: Dictionary = {}
		
		# Boxes
		var box_array: Array[Dictionary]
		
		for box in cell.boxes:
			var box_dict: Dictionary = {}
			
			box_dict["x_offset"] = box.rect.position.x
			box_dict["y_offset"] = box.rect.position.y
			box_dict["width"] = box.rect.size.x
			box_dict["height"] = box.rect.size.y
			box_dict["box_type"] = \
					box.type | box.crop_x_offset << 16 | box.crop_y_offset << 24
			
			box_array.append(box_dict)
		
		this_cell["boxes"] = box_array
		
		# Sprite Info
		var sprite_info: Dictionary = {}
		
		sprite_info["x_offset"] = cell.sprite_info.position.x
		sprite_info["y_offset"] = cell.sprite_info.position.y
		sprite_info["unk"] = cell.sprite_info.unknown
		sprite_info["index"] = cell.sprite_info.index
		
		this_cell["sprite_info"] = sprite_info
		
		array.append(JSON.stringify(this_cell, "  "))
	
	return array


func load_sprites_from_path(path: String) -> bool:
	if DirAccess.open(path) == null:
		return false
	
	# Load sprites
	sprites = SpriteLoader.load_sprites(path, Settings.sprite_reindex)

	return true


func load_cells_from_path(path: String) -> bool:
	if DirAccess.open(path) == null:
		return false
	
	# Load cells
	for file in FileSort.get_sorted_files(path, "json"):
		cells.append(Cell.from_file(file))
	
	return true
