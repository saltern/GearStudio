extends Window

@export var summon_button: Button

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	summon_button.pressed.connect(display)
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


func display() -> void:
	title = tr("SPRITE_EDIT_DELETE_TITLE").format({
		"name": sprite_edit.get_parent().name.right(-5)
	})
	show()
