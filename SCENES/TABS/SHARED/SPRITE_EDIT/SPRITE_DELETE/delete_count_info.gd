extends Label

@export var range_start: SpinBox
@export var range_end: SpinBox

@onready var sprite_edit: SpriteEdit = owner


func _ready() -> void:
	range_start.value_changed.connect(update.unbind(1))
	range_end.value_changed.connect(update.unbind(1))
	update()


func update() -> void:
	var delete_count: int = 1 + range_end.value - range_start.value
	
	if delete_count >= sprite_edit.sprite_get_count():
		text = "Cannot delete all sprites!"
	else:
		text = "Will delete %s sprite(s)." % delete_count
