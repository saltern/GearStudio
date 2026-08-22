extends Label

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	sprite_edit.sprite_updated.connect(on_sprite_updated)


func on_sprite_updated(sprite: BinSprite) -> void:
	if sprite.width == 0 or sprite.height == 0:
		text = "- x -"
	else:
		var tex_size: Vector2i = sprite.get_texture().get_size()
		text = "%s x %s" % [tex_size.x, tex_size.y]
	
	if sprite.bit_depth == 4 and sprite.width % 2 == 1:
		modulate = Color.ORANGE
		text = text + " (!)"
		mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		modulate = Color.WHITE
		mouse_filter = Control.MOUSE_FILTER_IGNORE
