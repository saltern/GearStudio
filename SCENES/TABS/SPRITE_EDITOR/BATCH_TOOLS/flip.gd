extends CheckButton

enum Mode {
	HORIZONTAL,
	VERTICAL,
}

@export var mode: Mode
@export var batch_tool: BatchProcessingTool


func _toggled(toggled_on: bool) -> void:
	match mode:
		Mode.HORIZONTAL:
			batch_tool.set_flip_h(toggled_on)
		Mode.VERTICAL:
			batch_tool.set_flip_v(toggled_on)
