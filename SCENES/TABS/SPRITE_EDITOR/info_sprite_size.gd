extends Label

@onready var editor: SpriteEditor = owner


func _ready() -> void:
	editor.info_outdated.connect(update)
	update()


func update() -> void:
	var sprite: BinSprite = editor.this_sprite
	text = "%d x %d" % [sprite.width, sprite.height]
	
	tooltip_text = "Allocated texture size:\n%d x %d" % [
		sprite.texture_width, sprite.texture_height
	]
