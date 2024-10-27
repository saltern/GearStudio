extends Button

@onready var palette_edit: PaletteEdit = owner


func _ready() -> void:
	pressed.connect(palette_edit.palette_reindex)
