extends OptionButton

const MAX_ICON_WIDTH: int = 22


func _ready() -> void:
	selected = Settings.cell_origin_type
	item_selected.connect(on_item_selected)
	load_options()


func load_options() -> void:
	for texture in Settings.get_origin_textures():
		var item_name: String = tr("PREFERENCES_CELLS_CROSS_BASE").format({
			"type": item_count
		})
		add_item(item_name, item_count)
		var this_index: int = item_count - 1
		set_item_icon(this_index, Settings.get_origin_icon(this_index))
		get_popup().set_item_icon_max_width(this_index, MAX_ICON_WIDTH)


func on_item_selected(item: int) -> void:
	Settings.set_origin_type(item)
