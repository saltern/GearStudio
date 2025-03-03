extends OptionButton


func _ready() -> void:
	item_selected.connect(on_item_selected)


func on_item_selected(item: int) -> void:
	Settings.cell_origin_type = item
	Settings.origin_type_changed.emit()
