extends OptionButton


func _ready() -> void:
	item_selected.connect(update)
	visibility_changed.connect(on_display)


func on_display() -> void:
	if visible:
		update(selected)


func update(item: int) -> void:
	SpriteImport.set_bit_depth(item)
