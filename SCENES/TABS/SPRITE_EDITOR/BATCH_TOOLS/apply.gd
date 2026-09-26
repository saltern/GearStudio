extends Button

@export var batch_tool: BatchProcessingTool


func _pressed() -> void:
	batch_tool.confirm_process()
