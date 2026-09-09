extends PopupMenu

enum ItemIndices {
	SOLID_BG,
}

@export var sprite_background: ColorRect


func _ready() -> void:
	index_pressed.connect(on_idx_pressed)


func on_idx_pressed(idx: int) -> void:
	match idx:
		ItemIndices.SOLID_BG:
			# Toggle
			set_item_checked(idx, !is_item_checked(idx))
			sprite_background.visible = is_item_checked(idx)
