class_name Cell extends Resource

@export_storage var boxes: Array[BoxInfo]
@export_storage var sprite_info: SpriteInfo


static func from_file(file_path: String) -> Cell:
	var file := FileAccess.open(file_path, FileAccess.READ)
	var text: String = file.get_as_text()
	var json: JSON = JSON.new()
	
	var error = json.parse(text)
	
	if error != OK:
		return Cell.new()
	
	var new_sprite_info: SpriteInfo = SpriteInfo.new()
	var new_boxes: Array[BoxInfo] = []
	
	for box in json.data["boxes"]:
		var new_box: BoxInfo = BoxInfo.new()
		
		new_box.rect = Rect2i(
			box["x_offset"], box["y_offset"],
			box["width"], box["height"])
		
		var int_type: int = box["box_type"]
		
		new_box.type = int_type & 0xFFFF
		new_box.crop_x_offset = (int_type >> 16) & 0xFF
		new_box.crop_y_offset = (int_type >> 24) & 0xFF
		
		new_boxes.append(new_box)

	if json.data.has("sprite_info"):
		var sprite = json.data["sprite_info"]
		new_sprite_info.index = sprite["index"]
		new_sprite_info.unknown = sprite["unk"]
		new_sprite_info.position = Vector2i(
			sprite["x_offset"],
			sprite["y_offset"])
	# Will crash when selecting as invalid cell
	#else:
		#new_sprite_info.index = 0
		#new_sprite_info.unknown = 0 # Flip information?
		#new_sprite_info.position = Vector2i(0,0)
	
	var new_cell: Cell = Cell.new()
	new_cell.sprite_info = new_sprite_info
	new_cell.boxes = new_boxes
	
	return new_cell
