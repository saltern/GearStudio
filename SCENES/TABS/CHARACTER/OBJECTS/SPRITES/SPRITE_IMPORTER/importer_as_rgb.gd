extends CheckButton


func _ready() -> void:
	toggled.connect(SpriteImport.set_as_rgb)
