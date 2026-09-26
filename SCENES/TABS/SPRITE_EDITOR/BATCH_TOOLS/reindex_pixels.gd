extends CheckButton

@export var batch_tool: BatchProcessingTool


func _toggled(toggled_on: bool) -> void:
	batch_tool.set_reindex_pixels(toggled_on)
