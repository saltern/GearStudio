extends PopupMenu

enum MenuID {
	ABOUT
}

@export var about_dialog: Control


func _ready() -> void:
	id_pressed.connect(menu_clicked)


func menu_clicked(id: int) -> void:
	match id:
		MenuID.ABOUT:
			about_dialog.show()
