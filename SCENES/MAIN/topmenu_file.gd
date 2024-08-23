extends PopupMenu

enum ButtonID {
	LOAD,
	SAVE,
	BUILD,
	SEPARATOR_0,
	CLOSE,
	SEPARATOR_1,
	EXIT,
}

const button_names: Dictionary = {
	ButtonID.LOAD: "Load...",
	ButtonID.SAVE: "Save",
	ButtonID.BUILD: "Build...",
	ButtonID.SEPARATOR_0: "",
	ButtonID.CLOSE: "Close",
	ButtonID.SEPARATOR_1: "",
	ButtonID.EXIT: "Exit",
}


@export var load_dialog: FileDialog


func _ready() -> void:
	for item in button_names:
		if button_names[item] == "":
			add_separator()
		else:
			add_item(button_names[item])
			
	id_pressed.connect(menu_clicked)


func menu_clicked(menu_id: int) -> void:
	match menu_id:
		ButtonID.LOAD:
			load_dialog.show()
