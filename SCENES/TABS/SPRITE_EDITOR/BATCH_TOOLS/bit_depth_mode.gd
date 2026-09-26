extends OptionButton

@export var batch_tool: BatchProcessingTool


func _ready() -> void:
	add_item("NO_CHANGE")
	add_item("SET_TO_4")
	add_item("SET_TO_8")
	item_selected.connect(batch_tool.set_depth_mode)
