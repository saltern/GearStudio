extends TextureRect

@export var reindex: CheckBox
@export var box_unknown: CheckBox
@export var box_hitbox: CheckBox
@export var box_hurtbox: CheckBox
@export var box_regions: CheckBox
@export var box_collision: CheckBox
@export var box_spawns: CheckBox
@export var origin: CheckBox

@onready var cell_edit: CellEdit = owner

func _ready() -> void:
	cell_edit.cell_updated.connect(on_cell_updated)


func on_cell_updated(cell: Cell) -> void:
	return
	var snapshot_coords: Rect2i = get_snapshot_coords(cell)
	var new_image := get_new_image(snapshot_coords, cell)
	draw_boxes(snapshot_coords, cell, new_image)
	texture = ImageTexture.create_from_image(new_image)


func get_new_image(snapshot_coords: Rect2i, cell: Cell) -> Image:
	var width: int = snapshot_coords.size.x
	var height: int = snapshot_coords.size.y
	
	var new_image: Image = Image.create_empty(
		width, height, false, Image.FORMAT_L8
	)
	
	var source_image: Image = cell_edit.sprite_get(cell.sprite_index).image
	var sprite_offset: Vector2i = Vector2i(
		cell.sprite_x_offset - 128,
		cell.sprite_y_offset - 128
	) + snapshot_coords.position
	
	if cell_has_regions(cell):
		for type in [3, 6]:
			for box in cell.boxes:
				if not box.box_type == type:
					continue
		
				new_image.blit_rect(
					source_image,
					Rect2i(box.x_offset, box.y_offset, box.width, box.height),
					Vector2i(
						8 * box.crop_x_offset + box.x_offset + sprite_offset.x,
						8 * box.crop_y_offset + box.y_offset + sprite_offset.y
					)
				)
	else:
		new_image.blit_rect(
			source_image, Rect2i(0, 0, width, height), sprite_offset
		)
	
	var palette: PackedByteArray = []
	
	if cell_edit.sprite_get(cell.sprite_index).palette.size() > 0:
		palette = cell_edit.sprite_get(cell.sprite_index).palette
	else:
		palette = cell_edit.obj_data["palettes"][0].palette
	
	var paletted_image := Image.create_empty(
		width, height, false, Image.FORMAT_RGBA8
	)
	
	if reindex.button_pressed:
		new_image.set_data(width, height, false, Image.FORMAT_L8,
			TransformTools.reindex_array(new_image.get_data())
		)
	
	for pixel in width * height:
		var color_index: int = new_image.get_pixel(
			pixel % width, pixel / width
		).r8
		
		color_index = min(color_index, palette.size() / 4 - 1)
		
		paletted_image.set_pixel(
			pixel % width,
			pixel / width,
			Color8(
				palette[4 * color_index + 0],
				palette[4 * color_index + 1],
				palette[4 * color_index + 2],
				palette[4 * color_index + 3] * 2,
			)
		)
	
	return paletted_image


func get_snapshot_coords(cell: Cell) -> Rect2i:
	var min_offset: Vector2i = Vector2i.ZERO
	var max_offset: Vector2i = Vector2i.ZERO
	var has_regions: bool = false
	
	for box in cell.boxes:
		if box.box_type in [3, 6]:
			has_regions = true
			continue
		
		min_offset.x = min(min_offset.x, box.x_offset)
		min_offset.y = min(min_offset.y, box.y_offset)
		max_offset.x = max(max_offset.x, box.x_offset + box.width)
		max_offset.y = max(max_offset.y, box.y_offset + box.height)
	
	# Full sprite
	if not has_regions:
		min_offset.x = min(min_offset.x, cell.sprite_x_offset - 128)
		min_offset.y = min(min_offset.y, cell.sprite_y_offset - 128)
		
		var sprite: BinSprite = cell_edit.sprite_get(cell.sprite_index)
		max_offset.x = max(
			max_offset.x, cell.sprite_x_offset - 128 + sprite.image.get_width()
		)
		max_offset.y = max(
			max_offset.y, cell.sprite_y_offset - 128 + sprite.image.get_height()
		)
	
	# Sprite with type 3/6
	else:
		for box in cell.boxes:
			if not box.box_type in [3, 6]:
				continue
			
			var crop_offset: Vector2i = Vector2i(
				box.crop_x_offset,
				box.crop_y_offset
			) * 8
			
			var sprite_offset: Vector2i = Vector2i(
				cell.sprite_x_offset - 128,
				cell.sprite_y_offset - 128
			)
			
			min_offset.x = min(
				min_offset.x,
				crop_offset.x + sprite_offset.x + box.x_offset
			)
			
			min_offset.y = min(
				min_offset.y,
				crop_offset.y + sprite_offset.y + box.y_offset
			)
			
			max_offset.x = max(
				max_offset.x,
				crop_offset.x + box.width + sprite_offset.x + box.x_offset
			)
			
			max_offset.y = max(
				max_offset.y,
				crop_offset.y + box.height + sprite_offset.y + box.y_offset
			)
	
	return Rect2i(-min_offset, max_offset - min_offset)


func cell_has_regions(cell: Cell) -> bool:
	for box in cell.boxes:
		if box.box_type in [3, 6]:
			return true
	
	return false


func draw_boxes(snapshot_coords: Rect2i, cell: Cell, image: Image) -> void:
	for box: BoxInfo in cell.boxes:
		if box.box_type in [3, 6]:
			continue
		
		# Top + bottom
		var base_coords: Vector2i = Vector2i(
			box.x_offset + snapshot_coords.position.x,
			box.y_offset + snapshot_coords.position.y
		)
		
		var color: Color = Settings.box_colors[box.box_type]
		
		for pixel in box.width:
			image.set_pixel(base_coords.x + pixel, base_coords.y, color)
			image.set_pixel(
				base_coords.x + pixel, base_coords.y + box.height - 1, color
			)
		
		# Left + right
		for pixel in box.height:
			image.set_pixel(base_coords.x, base_coords.y + pixel, color)
			image.set_pixel(
				base_coords.x + box.width - 1, base_coords.y + pixel, color
			)
