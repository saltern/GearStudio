extends OptionButton


func _ready() -> void:
	item_selected.connect(SpriteImport.set_placement_method)
