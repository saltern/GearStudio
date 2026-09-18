extends CenterContainer

@export var replacement_mode: OptionButton

@onready var editor: SpriteEditor = owner


func _ready() -> void:
	if editor.object_has_palettes():
		queue_free()
	replacement_mode.item_selected.connect(on_mode_set)


func on_mode_set(mode: int) -> void:
	visible = mode != 0
