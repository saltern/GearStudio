extends SteppingSpinBox

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	if sprite_edit.obj_data["type"] == "sprite":
		get_parent().hide()
		return
	
	SpriteImport.sprite_placement_finished.connect(on_sprites_imported)
	value_changed.connect(sprite_edit.sprite_set)
	sprite_edit.provider.palette_imported.connect(external_set_sprite)
	update_sprite_count()


func on_sprites_imported() -> void:
	update_sprite_count()
	sprite_edit.sprite_set(value)


func update_sprite_count() -> void:
	max_value = sprite_edit.sprite_get_count() - 1


func external_set_sprite(sprite_index: int) -> void:
	call_deferred("set_value_no_signal", sprite_index)
