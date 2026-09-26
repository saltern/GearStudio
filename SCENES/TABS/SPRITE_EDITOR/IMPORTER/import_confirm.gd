extends Button

@export var dialog: SpriteImportDialog
@export var confirmation_dialog: Window


func _ready() -> void:
	dialog.files_set.connect(on_files_set.unbind(1))
	disabled = true


func _pressed() -> void:
	confirmation_dialog.show()


func on_files_set() -> void:
	disabled = false
