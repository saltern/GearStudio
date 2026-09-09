extends ColorPicker

@export var pal_helper: PaletteEditorHelper
@export var selection_mgr: PaletteSelection

@onready var editor: SpriteEditor = owner

var last_color: Color


func _ready() -> void:
	selection_mgr.index_clicked.connect(on_index_clicked)
	color_changed.connect(on_color_changed)


func on_index_clicked(index: int) -> void:
	var sprite: BinSprite = editor.this_sprite
	color = sprite.get_color(index)
	last_color = sprite.get_color(index)


func on_color_changed(new_color: Color) -> void:
	var channels: Array[bool] = []
	
	channels.append(!is_equal_approx(last_color.r, new_color.r))
	channels.append(!is_equal_approx(last_color.g, new_color.g))
	channels.append(!is_equal_approx(last_color.b, new_color.b))
	channels.append(!is_equal_approx(last_color.a, new_color.a))
	
	pal_helper.set_color(new_color, channels)
	last_color = new_color
