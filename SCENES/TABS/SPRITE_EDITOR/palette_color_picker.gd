extends ColorPicker

@export var pal_helper: PaletteEditorHelper
@export var selection_mgr: PaletteSelection

@onready var editor: SpriteEditor = owner


func _ready() -> void:
	selection_mgr.index_clicked.connect(on_index_clicked)
	color_changed.connect(pal_helper.set_color)


func on_index_clicked(index: int) -> void:
	var sprite: BinSprite = editor.this_sprite
	color = sprite.get_color(index)
