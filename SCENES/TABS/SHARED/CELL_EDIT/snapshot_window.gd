extends Window

@export var summon_button: Button
@export var file_dialog: FileDialog
@export var cell_from: SteppingSpinBox
@export var cell_to: SteppingSpinBox


func _enter_tree() -> void:
	hide()


func _ready() -> void:
	summon_button.pressed.connect(display)
	close_requested.connect(hide)


func _input(event: InputEvent) -> void:
	if not visible: return
	if not event is InputEventKey: return
	if not event.is_pressed(): return
	if event.is_echo(): return
	
	if event.keycode == KEY_ESCAPE:
		hide()


func display() -> void:
	show()
