extends Button

@export var pal_helper: PaletteEditorHelper

@onready var editor: SpriteEditor = owner


func _pressed() -> void:
	if editor.this_sprite.bit_depth == BinSprite.DEPTH_4:
		Status.set_status(tr("STATUS_SPRITE_CANNOT_REINDEX"))
		return
	
	pal_helper.reindex()
