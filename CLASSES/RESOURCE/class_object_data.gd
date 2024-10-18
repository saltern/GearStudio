class_name ObjectData extends Resource

signal palette_updated
signal palette_selected

var name: String
var sprites: Array[BinSprite] = []
var cells: Array[Cell] = []
var palette_data: PaletteData = PaletteData.new()
var object_script: ObjectScript


func serialize_and_save(path: String) -> void:
	GlobalSignals.call_deferred("emit_signal", "save_object", name)
	var cell_json_array: Array[String] = serialize_cells()

	# Save cells
	if has_cells():
		DirAccess.make_dir_recursive_absolute("%s/cells" % path)
		GlobalSignals.call_deferred("emit_signal", "save_sub_object", "cells")
	
		for cell in cell_json_array.size():
			var new_json_file = FileAccess.open(
				"%s/cells/cell_%s.json" % [path, cell], FileAccess.WRITE)

			if FileAccess.get_open_error() != OK:
				SaveErrors.cell_save_error = true
				continue

			new_json_file.store_string(cell_json_array[cell])
			new_json_file.close()
	
	# Save sprites
	GlobalSignals.call_deferred("emit_signal", "save_sub_object", "sprites")
	DirAccess.make_dir_recursive_absolute("%s/sprites" % path)
	save_sprites_to_path("%s/sprites" % path)
	
	# Save palettes
	palette_data.serialize_and_save("%s/../palettes" % path)


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


func save_sprites_to_path(path: String) -> void:
	if DirAccess.open(path) == null:
		return
	
	# Save sprites
	SpriteLoadSave.save_sprites(sprites, path)


func load_sprites_from_path(path: String) -> bool:
	if DirAccess.open(path) == null:
		return false
	
	# Load sprites
	sprites = SpriteLoadSave.load_sprites(path)

	return true
	

func load_cells_from_path(path: String) -> bool:
	if DirAccess.open(path) == null:
		return false
	
	# Load cells
	for file in FileSort.get_sorted_files(path, "json"):
		cells.append(Cell.from_file(file))
	
	return true


func load_palette_data_from_path(path: String) -> bool:
	palette_data.load_palettes_from_path(path)
	return palette_data.palettes.size() > 0


#func load_script_from_file(path: String) -> bool:
	#object_script = ObjectScript.from_file(path)
	#return object_script.actions.size() > 0


# Surprisingly fast
func clamp_sprite_indices() -> void:
	var sprite_max: int = max(sprites.size() - 1, 0)
	
	for cell in cells:
		cell.sprite_info.index = clampi(
			cell.sprite_info.index, 0, sprite_max)


func sprite_get(index: int) -> BinSprite:
	if sprites.size() > index:
		return sprites[index]
	else:
		return BinSprite.new()


func sprite_get_count() -> int:
	return sprites.size()


func has_palettes() -> bool:
	return palette_data.palettes.size() > 0


func palette_get(index: int) -> BinPalette:
	if palette_data.palettes.size() > index:
		return palette_data.palettes[index]
	else:
		return BinPalette.new()


func palette_get_count() -> int:
	return palette_data.palettes.size()


func palette_broadcast(index: int) -> void:
	palette_selected.emit(index)


func has_cells() -> bool:
	return cells.size() > 0
