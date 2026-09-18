extends OptionButton

@export var dialog: SpriteImportDialog


func _ready() -> void:
	item_selected.connect(dialog.set_placement_method)
