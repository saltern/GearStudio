extends Button

enum Mode {
	HORIZONTAL,
	VERTICAL
}

@export var mode: Mode

@onready var editor: SpriteEditor = owner


func _pressed() -> void:
	var string: String
	var callable: Callable
	
	match mode:
		Mode.HORIZONTAL:
			string = "ACTION_SPRITE_FLIP_H"
			callable = editor.this_sprite.flip_h
		Mode.VERTICAL:
			string = "ACTION_SPRITE_FLIP_V"
			callable = editor.this_sprite.flip_v

	var undo_redo: UndoRedo = editor.undo_redo
	var action_text: String = tr(string).format({
		"index": editor.sprite_index
	})
	
	undo_redo.create_action(action_text)
	
	undo_redo.add_do_method(editor.force_sprite.bind(editor.sprite_index))
	undo_redo.add_do_method(callable)
	undo_redo.add_do_method(editor.notify_preview_outdated)
	
	undo_redo.add_undo_method(editor.force_sprite.bind(editor.sprite_index))
	undo_redo.add_undo_method(callable)
	undo_redo.add_undo_method(editor.notify_preview_outdated)

	editor.status_register_action(action_text)
	undo_redo.commit_action()
