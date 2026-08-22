extends Label

@onready var editor: SpriteEditor = owner


func _ready() -> void:
	editor.info_outdated.connect(update)
	update()


func update() -> void:
	match editor.this_sprite.bit_depth:
		BinSprite.DEPTH_4:
			text = "4 bpp"
		BinSprite.DEPTH_8:
			text = "8 bpp"
