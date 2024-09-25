extends Control

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	if sprite_edit.obj_data.name == "player":
		hide()
