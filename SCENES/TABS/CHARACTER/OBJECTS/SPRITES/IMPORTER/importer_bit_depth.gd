extends OptionButton


func _ready() -> void:
	toggled.connect(SpriteImport.set_bit_depth)
