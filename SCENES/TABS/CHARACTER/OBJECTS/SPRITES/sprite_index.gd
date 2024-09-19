extends SpinBox

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	SpriteImport.sprite_placement_finished.connect(on_sprites_imported)
	value_changed.connect(sprite_edit.sprite_set)
	
	update_sprite_count()


func on_sprites_imported() -> void:
	update_sprite_count()
	sprite_edit.sprite_set(value)


func update_sprite_count() -> void:
	max_value = sprite_edit.sprite_get_count() - 1
