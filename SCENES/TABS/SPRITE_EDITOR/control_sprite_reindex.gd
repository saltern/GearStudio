extends Button

@onready var editor: SpriteEditor = owner


func _pressed() -> void:
	var action_text: String = tr("ACTION_PROVIDER_SPRITE_REINDEX").format({
		"index": editor.sprite_index
	})
	
	var undo_redo: UndoRedo = editor.undo_redo
	
	undo_redo.create_action(action_text)
	undo_redo.add_do_method(editor.force_sprite.bind(editor.sprite_index))
	undo_redo.add_do_method(editor.this_sprite.reindex_pixels)
	undo_redo.add_do_method(editor.notify_preview_outdated)
	
	undo_redo.add_undo_method(editor.force_sprite.bind(editor.sprite_index))
	undo_redo.add_undo_method(editor.this_sprite.reindex_pixels)
	undo_redo.add_undo_method(editor.notify_preview_outdated)
	
	editor.status_register_action(action_text)
	undo_redo.commit_action()
