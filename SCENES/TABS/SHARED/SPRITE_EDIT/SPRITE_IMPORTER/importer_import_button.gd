extends Button

@export var confirmation_dialog: ConfirmationDialog

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	confirmation_dialog.confirmed.connect(ask_for_confirmation)
	pressed.connect(confirmation_dialog.show)


func ask_for_confirmation() -> void:
	confirmation_dialog.dialog_text = \
		"Import %s sprite(s)?" % SpriteImport.import_list.size()
	confirmation_dialog.show()


func on_import_confirm() -> void:
	SpriteImport.import_files(sprite_edit.obj_data)
