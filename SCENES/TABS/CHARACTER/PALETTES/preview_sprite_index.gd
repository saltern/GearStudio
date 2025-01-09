extends SteppingSpinBox

@onready var palette_edit: PaletteEdit = owner


func _ready() -> void:
	SpriteImport.sprite_placement_finished.connect(update)
	update()


func update() -> void:
	max_value = palette_edit.sprite_get_count() - 1
