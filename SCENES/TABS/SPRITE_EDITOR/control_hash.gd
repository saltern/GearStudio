extends SteppingSpinBox

@onready var editor: SpriteEditor = owner

var block: bool = false


func _ready() -> void:
	editor.info_outdated.connect(update)
	max_value = 0xFFFF
	update()


func update() -> void:
	block = true
	set_value_no_signal(editor.this_sprite.id_hash)
	block = false


func _value_changed(new_value: float) -> void:
	var action_text: String = tr("ACTION_SPRITE_SET_HASH").format({
		"index": editor.sprite_index
	})
	
	# Stupid, but it works
	# set_value_no_signal() seems to be emitting the signal all the same
	if block:
		return
	
	var undo_redo: UndoRedo = editor.undo_redo
	var sprite: BinSprite = editor.this_sprite
	var old_value: int = sprite.id_hash
	
	undo_redo.create_action(action_text, UndoRedo.MERGE_ENDS)
	
	undo_redo.add_do_property(sprite, "id_hash", new_value)
	undo_redo.add_do_method(editor.force_sprite.bind(editor.sprite_index))
	undo_redo.add_do_method(editor.notify_info_outdated)
	
	undo_redo.add_undo_property(sprite, "id_hash", old_value)
	undo_redo.add_undo_method(editor.force_sprite.bind(editor.sprite_index))
	undo_redo.add_undo_method(editor.notify_info_outdated)
	
	editor.status_register_action(action_text)
	undo_redo.commit_action()
