extends CheckButton

@onready var sprite_edit: SpriteEdit = owner


func _ready() -> void:
	toggled.connect(update)


func update(enabled: bool) -> void:
	sprite_edit.redirect_cells = enabled
