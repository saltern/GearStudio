extends Control

signal scale_set
signal rotation_set

@export var ignore_visual_toggle: CheckButton

@export var sprite_scale: Node2D
@export var sprite_scale_y: Node2D
@export var sprite_origin: Node2D

var session_id: int
var palette_index: int = 0

var angle: int = 0
var scale_x: int = -1
var scale_y: int = -1

var ignore_visual: bool = false

@onready var script_edit: ScriptEdit = owner


func _ready() -> void:
	SessionData.palette_changed.connect(load_palette)
	script_edit.cell_updated.connect(on_cell_loaded)
	script_edit.cell_clear.connect(unload_sprite)
	script_edit.inst_cell.connect(on_cell)
	script_edit.inst_semitrans.connect(on_semitrans)
	script_edit.inst_scale.connect(on_scale)
	script_edit.inst_rotate.connect(on_rotate)
	script_edit.inst_draw_normal.connect(on_draw_normal)
	script_edit.inst_draw_reverse.connect(on_draw_reverse)
	script_edit.inst_visual.connect(on_visual)
	ignore_visual_toggle.toggled.connect(toggle_visual)


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


func toggle_visual(enabled: bool) -> void:
	if enabled and not visible:
		visible = true
	
	ignore_visual = enabled


#region INSTRUCTION SIMULATION
func on_cell(index: int) -> void:
	if script_edit.cell_get_count() > index:
		var this_cell: Cell = script_edit.obj_data["cells"][index]
		on_cell_loaded(this_cell)
	else:
		unload_sprite()


func on_semitrans(mode: int, value: int) -> void:
	(material as ShaderMaterial).set_shader_parameter("blend_mode", mode)
	(material as ShaderMaterial).set_shader_parameter("blend_value", value)


func on_scale(mode: int, value: int) -> void:
	match mode:
		0:
			scale_x = value
		1:
			scale_y = value
		2:
			scale_x += value
		3:
			scale_y += value
		4:
			scale_x += randi_range(0, pow(256, 2) - 1) & value
		5:
			scale_y += randi_range(0, pow(256, 2) - 1) & value
		6:
			scale_x = (scale_x * float(value) / 100.00)
		7:
			scale_y = (scale_y * float(value) / 100.00)
	
	# Apply
	if scale_x == -1:
		sprite_scale.scale.x = 1.0
	else:
		sprite_scale.scale.x = float(scale_x) / 1000.00
	
	if scale_y == -1:
		sprite_scale.scale.y = sprite_scale.scale.x
	else:
		sprite_scale.scale.y = float(scale_y) / 1000.00

	scale_set.emit(scale_x, scale_y)


func on_rotate(mode: int, value: int) -> void:
	match mode:
		0:
			angle = value
		1:
			if value == 0:
				angle = randi_range(0, 255) << 8
			else:
				angle = randi_range(0, pow(256, 2) - 1) & value
		2:
			angle += value
		3:
			# Depends on object's localid...
			# Unimplemented at this time
			pass
		4:
			angle += randi_range(0, pow(256, 2) - 1) & value
		5:
			# Original code is:
			# rng2 = Random(&RandomSeed);
			# offset->angle = offset->angle + (short)((ulonglong)rng2 % (ulonglong)ip->arg2);
			
			# Random returns a 4-byte int anyway, so the cast to ulonglong
			# probably doesn't do anything. The random number is modulo-ed with
			# the value parameter, then the whole thing is cast to a short, and
			# added to the current angle.
			
			value = max(value, 1)
			angle += (randi_range(0, pow(256, 4) - 1) % value) & 0xFFFF
	
	rotation_degrees = (90.0 / pow(128, 2)) * angle
	rotation_set.emit(rotation_degrees)


func on_draw_normal() -> void:
	scale.x = 1


func on_draw_reverse() -> void:
	scale.x = -1


func on_visual(mode: int, value: int) -> void:
	if ignore_visual:
		return
	
	match mode:
		0:
			visible = bool(value)
		3:
			material.set_shader_parameter("visual_3", bool(value))
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
