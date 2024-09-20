extends Button

@export var window: Window

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	pressed.connect(on_import_clicked)


func on_import_clicked() -> void:
	SpriteImport.obj_data = sprite_edit.obj_data
	SpriteImport.pal_data = sprite_edit.pal_data
	window.show()
