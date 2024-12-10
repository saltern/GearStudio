extends ConfirmationDialog

@export var delete_from: SpinBox
@export var delete_to: SpinBox
@export var summon_button: Button
@export var cannot_delete: AcceptDialog

@onready var sprite_edit: SpriteEdit = get_owner()


func _ready() -> void:
	summon_button.pressed.connect(display)
	confirmed.connect(delete_sprites)


func display() -> void:
	var delete_count: int = delete_to.value - delete_from.value + 1
	
	if delete_count >= sprite_edit.obj_data.sprites.size():
		cannot_delete.show()
		return
	
	dialog_text = tr("SPRITE_EDIT_DELETE_CONFIRM_TEXT").format({
		"count": delete_count
	})
	show()


func delete_sprites() -> void:
	sprite_edit.sprite_delete(delete_from.value, delete_to.value)
