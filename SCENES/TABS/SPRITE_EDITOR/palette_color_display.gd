class_name PaletteDisplay extends Control

@export var direct_mode: bool
@export var pal_helper: PaletteEditorHelper
@export var selection: PaletteSelection

const COLUMNS: int = 16
const TILE_SIZE: int = 17
const DRAW_SIZE: int = 16
const DRAW_OFFSET: int = 1

var palette: PackedByteArray


func _ready() -> void:
	get_parent().resized.connect(resize)
	
	if !direct_mode:
		pal_helper.sprite_updated.connect(update)
		selection.selection_changed.connect(queue_redraw.unbind(3))
	
	update()


func _draw() -> void:
	var color_count: int
	
	if direct_mode:
		if palette.is_empty():
			return
		color_count = BinSprite.COLOR_COUNT_8_FULL
	else:
		palette = pal_helper.get_palette()
		color_count = pal_helper.get_color_count()
	
		if selection.reordering:
			palette = selection.get_reordered_colors()
	
	
	for i: int in color_count:
		var x: int = i % COLUMNS
		var y: int = i / COLUMNS
		var r: Rect2i = Rect2i(
			TILE_SIZE * x + DRAW_OFFSET,
			TILE_SIZE * y + DRAW_OFFSET,
			DRAW_SIZE, DRAW_SIZE
		)
		
		var color: Color = Color8(
			palette[4 * i + 0],
			palette[4 * i + 1],
			palette[4 * i + 2],
			clampi(palette[4 * i + 3] * 2, 0x00, 0xFF),
		)
		
		draw_rect(r, color)


func resize() -> void:
	custom_minimum_size = get_parent().custom_minimum_size


func update() -> void:
	queue_redraw()
	resize()


func set_palette(new_palette: PackedByteArray) -> void:
	palette = new_palette
	update()
