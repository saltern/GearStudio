extends PopupMenu

enum ButtonID {
	DECRYPT_FOLDER
}

const button_names: Dictionary = {
	ButtonID.DECRYPT_FOLDER: "TOOLS_DECRYPT_FOLDER"
}

@export var decrypt_browser: FileDialog
@export var decrypt_confirm: ConfirmationDialog


func _ready() -> void:
	for item in button_names:
		add_item(button_names[item])
	
	id_pressed.connect(menu_clicked)
	
	decrypt_browser.dir_selected.connect(on_decrypt_dir_selected)


func menu_clicked(button_id: int) -> void:
	match button_id:
		ButtonID.DECRYPT_FOLDER:
			decrypt_browser.show()


func on_decrypt_dir_selected(path: String) -> void:
	decrypt_browser.hide()
	decrypt_confirm.display(path)
