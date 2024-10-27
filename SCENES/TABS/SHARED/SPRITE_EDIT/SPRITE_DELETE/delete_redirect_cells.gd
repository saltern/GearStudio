extends CheckButton


func _ready() -> void:
	toggled.connect(update)


func update(enabled: bool) -> void:
	SpriteImport.redirect_cells = enabled
