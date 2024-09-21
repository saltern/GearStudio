extends ConfirmationDialog

@export var delete_from: SpinBox
@export var delete_to: SpinBox

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	confirmed.connect(delete_sprites)


func display() -> void:
	var delete_count: int = delete_to.value - delete_from.value + 1
	dialog_text = "Really delete %s sprite(s)?" % delete_count
	show()


func delete_sprites() -> void:
	sprite_edit.sprite_delete(delete_from.value, delete_to.value)
