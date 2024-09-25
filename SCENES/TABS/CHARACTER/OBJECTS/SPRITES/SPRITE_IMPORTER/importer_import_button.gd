extends Button

@export var confirmation_dialog: ConfirmationDialog


func _ready() -> void:
	pressed.connect(on_import_confirm)


func on_import_confirm() -> void:
	SpriteImport.import_files(get_owner().get_parent().name)
