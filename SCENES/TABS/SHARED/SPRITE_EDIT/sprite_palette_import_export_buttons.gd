extends Control

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	if not sprite_edit.obj_data.has("name"):
		return

	if sprite_edit.obj_data.has("palettes"):
		queue_free()
