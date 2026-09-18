extends OptionButton

@export var dialog: SpriteImportDialog


func _ready() -> void:
	item_selected.connect(on_item_selected)


func on_item_selected(item: SpriteImportDialog.BitDepthMode) -> void:
	dialog.set_sprite_bit_depth(item)
