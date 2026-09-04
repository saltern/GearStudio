extends TextureRect

const COLUMNS: int = 16
const TILE_SIZE: int = 17

@export var by_channel: CheckButton
@export var selection_mgr: PaletteSelection
@export var picker: ColorPicker

@onready var editor: SpriteEditor = owner


func _ready() -> void:
	editor.preview_outdated.connect(update)
	by_channel.toggled.connect(on_by_channel_toggled)
	update()


func update() -> void:
	var sprite: BinSprite = editor.this_sprite
	var color_count: int = sprite.get_color_count()
	
	var rows: int = color_count / COLUMNS
	custom_minimum_size.y = TILE_SIZE * rows + 1
	
	if color_count < sprite.COLOR_COUNT_4_FULL:
		custom_minimum_size.x = TILE_SIZE * color_count + 1
	else:
		custom_minimum_size.x = TILE_SIZE * COLUMNS + 1


func on_by_channel_toggled(toggled_on: bool) -> void:
	if toggled_on:
		picker.color_mode = ColorPicker.MODE_RGB
		picker.color_modes_visible = false
	else:
		picker.color_modes_visible = true
