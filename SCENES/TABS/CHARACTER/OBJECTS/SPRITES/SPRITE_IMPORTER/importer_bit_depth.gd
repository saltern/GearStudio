extends OptionButton


func _ready() -> void:
	item_selected.connect(SpriteImport.set_bit_depth)
	#toggled.connect(SpriteImport.set_bit_depth)
