extends Window

@export var summon_button: Button


func _ready() -> void:
	summon_button.pressed.connect(show)
	close_requested.connect(hide)


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if not event is InputEventKey:
		return
	if not event.pressed:
		return
	if event.is_echo():
		return
	
	if event.keycode == KEY_ESCAPE:
		hide()
