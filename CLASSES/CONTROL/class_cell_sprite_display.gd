class_name CellSpriteDisplay extends Control

@export var sprite_origin: CanvasItem

var sprite_index: int = 0
var palette_index: int = 0

var visual_1: bool = false

var provider: Node


func _enter_tree() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func load_cell(cell: Cell) -> void:
	if cell.sprite_index < provider.obj_data.sprites.size():
		sprite_index = cell.sprite_index
		load_cell_sprite(sprite_index, cell.boxes)
	
	else:
		unload_sprite()
	
	sprite_origin.position.x = cell.sprite_x_offset
	sprite_origin.position.y = cell.sprite_y_offset


func unload_sprite() -> void:
	for child in sprite_origin.get_children():
		child.queue_free()


func load_cell_sprite(index: int, boxes: Array[BoxInfo]) -> void:
	unload_sprite()
	
	var cutout_list: Array[Rect2i] = []
	var offset_list: Array[Vector2i] = []
	var v_flip_list: Array[bool] = []
	
	# Type 6 crops appear in front of type 3 crops, add them later
	# (Thanks Athenya)
	for type in [3, 6]:
		for box in boxes:
			if box.box_type != type:
				continue
			
			var offset_x: int = 8 * box.crop_x_offset
			var offset_y: int = 8 * box.crop_y_offset
			
			offset_list.append(Vector2i(offset_x, offset_y))
			
			var cutout := Rect2i(
				box.x_offset, box.y_offset, box.width, box.height
			)
			
			cutout_list.append(cutout)
	
	# Also-- type 6 cutouts are flipped vertically when the script
	# has a mode 1 "VISUAL" instruction
	for box in boxes:
		if box.box_type in [3, 6]:
			v_flip_list.append(box.box_type == 6)
	
	load_cell_sprite_pieces(index, cutout_list, offset_list, v_flip_list)
	material.set_shader_parameter("palette", get_palette(index))


func load_cell_sprite_pieces(
	index: int, rects: Array[Rect2i], offsets: Array[Vector2i], v_flips: Array[bool]
) -> void:
	var sprite: BinSprite = provider.obj_data.sprites[index]
	
	if not provider.obj_data.has("palettes"):
		material.set_shader_parameter("reindex", sprite.bit_depth == 8)
	else:
		material.set_shader_parameter("reindex", true)
	
	var source_image := sprite.image
	
	if rects.is_empty():
		rects.append(Rect2i(0, 0, 
			source_image.get_width(),
			source_image.get_height()))
		
		offsets.append(Vector2i.ZERO)
		v_flips.append(false)
	
	# Likely slower, but more accurate (?) representation
	for rect in rects.size():
		var new_tex: TextureRect = TextureRect.new()
		new_tex.mouse_filter = MOUSE_FILTER_IGNORE
		new_tex.position = (offsets[rect] + rects[rect].position) - Vector2i(128, 128)
		
		if v_flips[rect] and visual_1:
			new_tex.position.y += rects[rect].size.y
			new_tex.scale.y = -1
		
		var empty_pixels: PackedByteArray = []
		empty_pixels.resize(rects[rect].size.x * rects[rect].size.y)
		
		var target_image := Image.create_from_data(
			rects[rect].size.x,
			rects[rect].size.y,
			false, Image.FORMAT_L8, empty_pixels
		)
		
		target_image.blit_rect(
			source_image,
			rects[rect],
			Vector2i(0,0)
		)
		
		new_tex.texture = ImageTexture.create_from_image(target_image)
		new_tex.use_parent_material = true
		sprite_origin.add_child(new_tex)


func get_palette(index: int) -> PackedByteArray:
	# Global palette
	if provider.obj_data.has("palettes"):
		return provider.obj_data.palettes[palette_index].palette
	
	# Embedded palette
	var sprite: BinSprite = provider.obj_data.sprites[index]
	return sprite.palette


func load_palette(index: int) -> void:
	palette_index = index
	material.set_shader_parameter("palette", get_palette(palette_index))


func reload_palette() -> void:
	if provider.obj_data.has("palettes"):
		load_palette(palette_index)
	else:
		load_palette(sprite_index)
