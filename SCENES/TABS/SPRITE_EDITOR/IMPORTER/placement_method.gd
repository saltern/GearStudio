extends OptionButton

@export var dialog: SpriteImportDialog


func _ready() -> void:
	add_item("SPRITE_EDIT_IMPORT_PLACEMENT_APPEND")
	add_item("SPRITE_EDIT_IMPORT_PLACEMENT_INSERT")
	add_item("SPRITE_EDIT_IMPORT_PLACEMENT_REPLACE")
	item_selected.connect(dialog.set_placement_method)
