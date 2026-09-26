extends CheckButton

@export var batch_tool: BatchProcessingTool

@onready var editor: SpriteEditor = owner


func _ready() -> void:
	if editor.object_has_palettes():
		hide()
		queue_free()
	

func _toggled(toggled_on: bool) -> void:
	batch_tool.set_reindex_palettes(toggled_on)
