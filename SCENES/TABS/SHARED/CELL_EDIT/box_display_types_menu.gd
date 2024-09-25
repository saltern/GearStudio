extends MenuButton

@onready var cell_edit: CellEdit = get_owner()
@onready var popup: PopupMenu = get_popup()


func _ready() -> void:
	popup.hide_on_checkable_item_selection = false
	popup.id_pressed.connect(on_item_clicked)


func on_item_clicked(id: int) -> void:
	popup.toggle_item_checked(id)
	cell_edit.box_set_type_visible(id, popup.is_item_checked(id))
