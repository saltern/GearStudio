extends OptionButton


func _ready() -> void:
	selected = Settings.cell_snapshot_format
	item_selected.connect(on_item_selected)


func on_item_selected(item: int) -> void:
	Settings.cell_snapshot_format = item as Settings.SnapshotFormat
