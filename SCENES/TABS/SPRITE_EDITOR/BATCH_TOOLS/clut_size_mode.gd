extends OptionButton

@export var batch_tool: BatchProcessingTool


func _ready() -> void:
	add_item("NO_CHANGE")
	add_item("REMOVE")
	add_item("SET_TO_HALF")
	add_item("SET_TO_FULL")
	item_selected.connect(batch_tool.set_clut_mode)
