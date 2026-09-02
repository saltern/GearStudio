extends Button

@onready var editor: SpriteEditor = owner


func _pressed() -> void:
	var action_text: String = tr("ACTION_SPRITE_CUT_DEPTH").format({
		"index": editor.sprite_index
	})
	
	var undo_redo: UndoRedo = editor.undo_redo
	var sprite: BinSprite = editor.this_sprite
	
	var old_pixels: PackedByteArray = sprite.pixels.duplicate()
	var old_palette: PackedByteArray = sprite.palette.duplicate()
	
	undo_redo.create_action(action_text)
	undo_redo.add_do_method(editor.force_sprite.bind(editor.sprite_index))
	undo_redo.add_do_method(sprite.cut_bit_depth)
	undo_redo.add_do_method(editor.notify_info_outdated)
	undo_redo.add_do_method(editor.notify_preview_outdated)
	
	undo_redo.add_undo_method(editor.force_sprite.bind(editor.sprite_index))
	undo_redo.add_undo_property(sprite, "bit_depth", sprite.bit_depth)
	undo_redo.add_undo_method(restore_sprite.bind(sprite, old_pixels, old_palette))
	undo_redo.add_undo_method(sprite.update_preview)
	undo_redo.add_undo_method(editor.notify_info_outdated)
	undo_redo.add_undo_method(editor.notify_preview_outdated)
	
	editor.status_register_action(action_text)
	undo_redo.commit_action()


# I don't necessarily like this, but it's a pass-by-reference world out here.
func restore_sprite(
	sprite: BinSprite, pixels: PackedByteArray, palette: PackedByteArray
) -> void:
	sprite.pixels = pixels.duplicate()
	sprite.palette = palette.duplicate()
