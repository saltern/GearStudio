extends Button

@export var confirmation_dialog: ConfirmationDialog

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	confirmation_dialog.confirmed.connect(on_import_confirm)
	pressed.connect(ask_for_confirmation)


func ask_for_confirmation() -> void:
	if SpriteImport.import_list.size() == 0:
		Status.set_status("No sprites selected, can't import.")
		return
		
	confirmation_dialog.dialog_text = \
		"Import %s sprite(s)?" % SpriteImport.import_list.size()
	confirmation_dialog.show()


func on_import_confirm() -> void:
	SpriteImport.undo_redo = sprite_edit.undo_redo
	SpriteImport.import_files(sprite_edit.obj_data)
