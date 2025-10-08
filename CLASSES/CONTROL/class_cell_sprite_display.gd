class_name CellSpriteDisplay extends Control

@export var sprite_origin: CanvasItem

var sprite_index: int = 0
var palette_index: int = 0

var visual_1: bool = false

var provider: Object


func _enter_tree() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST


func load_cell(cell: Cell) -> void:
	unload_sprite()
	
	if cell.sprite_index >= provider.obj_data.sprites.size():
		return
	
	sprite_index = cell.sprite_index
	
	var sprite: BinSprite = provider.obj_data.sprites[cell.sprite_index]
	var region_dict: Dictionary = cell.rebuild_sprite(sprite, visual_1)
	
	for region in region_dict:
		var new_texture_rect: TextureRect = TextureRect.new()
		new_texture_rect.position.x = region_dict[region].x_offset - 128
		new_texture_rect.position.y = region_dict[region].y_offset - 128
		new_texture_rect.texture = region_dict[region].texture
		new_texture_rect.use_parent_material = true
		new_texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		sprite_origin.add_child(new_texture_rect)

	material.set_shader_parameter("palette", get_palette(cell.sprite_index))
	material.set_shader_parameter("reindex", should_reindex(sprite))
	
	sprite_origin.position.x = cell.sprite_x_offset
	sprite_origin.position.y = cell.sprite_y_offset


func unload_sprite() -> void:
	#print_debug("Unloading sprite")
	for child in sprite_origin.get_children():
		child.queue_free()


func get_palette(index: int) -> PackedByteArray:
	# Global palette
	if provider.obj_data.has("palettes"):
		if palette_index >= provider.obj_data.palettes.size():
			palette_index = 0
		return provider.obj_data.palettes[palette_index].palette
	
	# Embedded palette
	index = mini(index, provider.obj_data.sprites.size() - 1)
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


func should_reindex(sprite: BinSprite) -> bool:
	if not SessionData.session_get_reindex(provider.session_id):
		return false
	
	if not provider.obj_data.has("palettes"):
		return sprite.bit_depth == 8
	
	return true
