extends PopupMenu

enum ItemIDs {
	REINDEX,
}

@onready var session_id: int = get_parent().session_id


func _ready() -> void:
	add_check_item("Reindex 8bpp palettes in previews", ItemIDs.REINDEX)
	set_item_checked(ItemIDs.REINDEX, Settings.general_reindex_mode)
	index_pressed.connect(on_index_pressed)


func on_index_pressed(index: int) -> void:
	match index:
		ItemIDs.REINDEX:
			toggle_item_checked(index)
			SessionData.session_set_reindex(
				get_parent().session_id,
				is_item_checked(index)
			)
