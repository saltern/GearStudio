extends ConfirmationDialog

@export var summon_button: Button
@export var range_start: SteppingSpinBox
@export var range_end: SteppingSpinBox


func _ready() -> void:
	summon_button.pressed.connect(display)
	confirmed.connect(hide)


func display() -> void:
	var count: int = range_end.value - range_start.value + 1
	dialog_text = tr("SPRITE_EDIT_BATCH_REPAL_CONFIRM_TEXT").format({
		"count": count
	})
	show()
