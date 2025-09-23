extends OptionButton


func _ready() -> void:
	selected = Settings.pal_reindex_mode as int
	item_selected.connect(on_item_selected)


func on_item_selected(item: int) -> void:
	Settings.set_palette_reindex_mode(item as Settings.ReindexMode)
