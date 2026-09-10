extends PopupMenu

enum Options {
	BATCH_PROCESSING
}

@export var batch_dialog: Window


func _ready() -> void:
	index_pressed.connect(on_index_pressed)


func on_index_pressed(index: int) -> void:
	match index:
		Options.BATCH_PROCESSING:
			batch_dialog.show()
