extends Button

@onready var sprite_edit: SpriteEdit = owner


func _ready() -> void:
	pressed.connect(sprite_edit.sprite_reindex)
