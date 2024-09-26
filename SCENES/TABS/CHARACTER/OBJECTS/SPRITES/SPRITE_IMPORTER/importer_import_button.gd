extends Button

@export var confirmation_dialog: ConfirmationDialog

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	pressed.connect(on_import_confirm)


func on_import_confirm() -> void:
	SpriteImport.import_files(sprite_edit.obj_data.name)
