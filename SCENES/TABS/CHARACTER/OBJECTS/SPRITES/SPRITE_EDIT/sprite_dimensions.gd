extends Label

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	sprite_edit.sprite_updated.connect(on_sprite_updated)


func on_sprite_updated(sprite: BinSprite) -> void:
	if sprite.texture == null:
		text = "- x -"
	else:
		var tex_size: Vector2i = sprite.texture.get_size()
		text = "%s x %s" % [tex_size.x, tex_size.y]
