extends CheckButton


func _ready() -> void:
	toggled.connect(SpriteImport.set_halve_alpha)
