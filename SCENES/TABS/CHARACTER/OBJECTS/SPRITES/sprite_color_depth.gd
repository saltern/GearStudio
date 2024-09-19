extends Label

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	sprite_edit.sprite_updated.connect(on_sprite_updated)


func on_sprite_updated(sprite: BinSprite) -> void:
	text = "%s bpp" % sprite.bit_depth
