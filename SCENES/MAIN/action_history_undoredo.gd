extends Button

enum Mode {
	UNDO,
	REDO,
}

@export var mode: Mode


func _pressed() -> void:
	match mode:
		Mode.UNDO:
			GlobalSignals.menu_undo.emit()
		Mode.REDO:
			GlobalSignals.menu_redo.emit()
