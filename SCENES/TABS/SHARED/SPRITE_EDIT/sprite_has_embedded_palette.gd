extends Label

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	sprite_edit.sprite_updated.connect(on_sprite_updated)


func on_sprite_updated(sprite: BinSprite) -> void:
	if sprite.palette.is_empty():
		text = "SPRITE_EDIT_INFO_EMBEDDED_PALETTE_NO"
	else:
		text = "SPRITE_EDIT_INFO_EMBEDDED_PALETTE_YES"
