class_name PaletteDisplay extends Control

@export var pal_helper: PaletteEditorHelper
@export var selection: PaletteSelection

const COLUMNS: int = 16
const TILE_SIZE: int = 17
const DRAW_SIZE: int = 16
const DRAW_OFFSET: int = 1


func _ready() -> void:
	get_parent().resized.connect(resize)
	pal_helper.sprite_updated.connect(update)
	selection.selection_changed.connect(queue_redraw)
	update()


func _draw() -> void:
	var palette: PackedByteArray = pal_helper.get_palette()
	
	if selection.reordering:
		palette = selection.get_reordered_colors()
	
	for i: int in palette.size() / 4:
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
