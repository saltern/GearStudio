extends Label

@onready var editor: SpriteEditor = owner


func _ready() -> void:
	editor.info_outdated.connect(update)
	update()


func update() -> void:
	var sprite: BinSprite = editor.this_sprite
	text = "%s bpp | %s x %s (%s x %s)" % [
		sprite.bit_depth,
		sprite.width, sprite.height,
		sprite.texture_width, sprite.texture_height,
	]
