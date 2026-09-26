extends OptionButton

@export var batch_tool: BatchProcessingTool
@export var file_browser: FileDialog


func _ready() -> void:
	add_item("NO_CHANGE")
	add_item("FROM_CLIPBOARD")
	add_item("FROM_FILE")
	item_selected.connect(batch_tool.set_palette_mode)
	item_selected.connect(on_item_selected)


func on_item_selected(item: int) -> void:
	if item == BatchProcessingTool.PaletteSetting.FROM_FILE:
		file_browser.show()
