extends FileDialog

@export var batch_tool: BatchProcessingTool


func _ready() -> void:
	file_selected.connect(batch_tool.import_palette)
