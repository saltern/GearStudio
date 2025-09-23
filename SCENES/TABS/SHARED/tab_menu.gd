extends PopupMenu

enum ItemIDs {
	REINDEX,
}

@onready var session_id: int = get_parent().session_id


func _ready() -> void:
	add_check_item("Reindex 8bpp palettes in previews", ItemIDs.REINDEX)
	index_pressed.connect(on_index_pressed)


func on_index_pressed(index: int) -> void:
	match index:
		ItemIDs.REINDEX:
			toggle_item_checked(index)
			SessionData.session_set_reindex(
				get_parent().session_id,
				is_item_checked(index)
			)
