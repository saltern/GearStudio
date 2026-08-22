extends FoldableContainer

@onready var editor: SpriteEditor = owner


func _ready() -> void:
	if editor.object_has_palettes():
		queue_free()
