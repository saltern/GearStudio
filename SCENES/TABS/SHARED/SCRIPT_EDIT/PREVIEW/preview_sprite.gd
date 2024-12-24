extends Control

var session_id: int
var obj_data: Dictionary

var palette_index: int = 0

@onready var script_edit: ScriptEdit = owner
@onready var sprite_origin: Node2D = get_child(0)


func _ready() -> void:
	script_edit.cell_updated.connect(on_cell_loaded)
	script_edit.cell_clear.connect(unload_sprite)
	script_edit.inst_scale.connect(on_scale)
	script_edit.inst_draw_normal.connect(on_draw_normal)
	script_edit.inst_draw_reverse.connect(on_draw_reverse)
	SessionData.palette_changed.connect(load_palette)


func on_cell_loaded(cell: Cell) -> void:
	if cell.sprite_index < script_edit.sprite_get_count():
		load_cell_sprite(cell.sprite_index, cell.boxes)
	
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
	
	# Type 6 crops appear in front of type 3 crops, add them later
	# (Thanks Athenya)
	for type in [3, 6]:
		for box in boxes:
			if box.box_type != type: continue
			
			var offset_x: int = 8 * box.crop_x_offset
			var offset_y: int = 8 * box.crop_y_offset
			
			offset_list.append(Vector2i(offset_x, offset_y))
			cutout_list.append(Rect2i(
				box.x_offset, box.y_offset, box.width, box.height
			))
	
	load_cell_sprite_pieces(index, cutout_list, offset_list)
	material.set_shader_parameter("palette", get_palette(index))


func load_cell_sprite_pieces(
	index: int, rects: Array[Rect2i], offsets: Array[Vector2i]
) -> void:
	var sprite: BinSprite = script_edit.sprite_get(index)
	
	if not script_edit.obj_data.has("palettes"):
		material.set_shader_parameter("reindex", sprite.bit_depth == 8)
	
	var source_image := sprite.image
	
	if rects.is_empty():
		rects.append(Rect2i(0, 0, 
			source_image.get_width(),
			source_image.get_height()))
		
		offsets.append(Vector2i.ZERO)
	
	# Likely slower, but more accurate (?) representation
	for rect in rects.size():
		var new_tex: TextureRect = TextureRect.new()
		new_tex.mouse_filter = MOUSE_FILTER_IGNORE
		new_tex.position = (offsets[rect] + rects[rect].position) - Vector2i(128, 128)
		
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


#region INSTRUCTION SIMULATION
func on_scale(arguments: Array) -> void:
	var values: Array[int]
	values.assign(arguments)
	var fvalue: float = values[1] / 1000.00
	
	#print(values)
	
	match values[0]: #mode
		0:
			scale.x = fvalue
			scale.y = fvalue
			pass #scale = value
		1:
			scale.y = fvalue
			pass #scaleY = value
		2:
			scale.x += fvalue
			scale.y += fvalue
			pass #scale += value
		3:
			scale.y += fvalue
			pass #scaleY += value
		4:
			pass #scale = scale + (rng AND value)
		5:
			pass #scaleY = scaleY + (rng AND value)
		6:
			scale.x = (scale.x * (fvalue / 100.00))
			scale.y = (scale.y * (fvalue / 100.00))
			pass #scale = (scale * (value / 100.00))
		7:
			scale.y = (scale.y * (fvalue / 100.00))
			pass #scaleY = (scaleY * (value / 100.00))


func on_draw_normal() -> void:
	scale.x = 1


func on_draw_reverse() -> void:
	scale.x = -1
#endregion


func get_palette(index: int) -> PackedByteArray:
	# Global palette
	if script_edit.obj_data.has("palettes"):
		return script_edit.palette_get(palette_index).palette
	
	# Embedded palette
	var sprite: BinSprite = script_edit.sprite_get(index)
	return sprite.palette


func load_palette(for_session: int, pal_index: int) -> void:
	if for_session != session_id:
		return
	
	if not script_edit.obj_data.has("palettes"):
		return
		
	palette_index = pal_index
	material.set_shader_parameter("palette", get_palette(palette_index))
