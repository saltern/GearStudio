extends Button

enum Property {
	BIT_DEPTH,
	CLUT_SIZE,
	CLUT,
}

const ACTION_TEXT: Dictionary = {
	Property.BIT_DEPTH: "ACTION_SPRITE_TOGGLE_DEPTH",
	Property.CLUT_SIZE: "ACTION_SPRITE_TOGGLE_CLUT_SIZE",
	Property.CLUT: "ACTION_SPRITE_TOGGLE_CLUT"
}

@export var property: Property

@onready var editor: SpriteEditor = owner


func _pressed() -> void:
	var undo_redo: UndoRedo = editor.undo_redo
	var sprite: BinSprite = editor.this_sprite
	
	var action_text: String = tr(ACTION_TEXT[property]).format({
		"index": editor.sprite_index
	})
	
	undo_redo.create_action(action_text)
	
	undo_redo.add_do_method(editor.force_sprite.bind(editor.sprite_index))
	undo_redo.add_undo_method(editor.force_sprite.bind(editor.sprite_index))
	
	match property:
		Property.BIT_DEPTH:
			undo_redo.add_do_method(sprite.toggle_bit_depth)
			undo_redo.add_undo_method(sprite.toggle_bit_depth)
			
		Property.CLUT_SIZE:
			undo_redo.add_do_method(sprite.toggle_clut_size)
			undo_redo.add_undo_method(sprite.toggle_clut_size)
			
		Property.CLUT:
			undo_redo.add_do_method(sprite.toggle_clut)
			undo_redo.add_undo_method(sprite.toggle_clut)
	
	var old_palette: PackedByteArray = sprite.palette.duplicate()
	undo_redo.add_undo_method(restore_palette.bind(sprite, old_palette))
	
	var old_pixels: PackedByteArray = sprite.pixels.duplicate()
	undo_redo.add_undo_method(restore_pixels.bind(sprite, old_pixels))

	undo_redo.add_do_method(sprite.update_preview)
	undo_redo.add_do_method(editor.notify_info_outdated)
	undo_redo.add_do_method(editor.notify_preview_outdated)
	
	undo_redo.add_undo_method(sprite.update_preview)
	undo_redo.add_undo_method(editor.notify_info_outdated)
	undo_redo.add_undo_method(editor.notify_preview_outdated)
	
	editor.status_register_action(action_text)
	undo_redo.commit_action()


# I don't necessarily like this, but it's a pass-by-reference world out here.
func restore_pixels(sprite: BinSprite, pixels: PackedByteArray) -> void:
	sprite.pixels = pixels.duplicate()


func restore_palette(sprite: BinSprite, palette: PackedByteArray) -> void:
	sprite.palette = palette.duplicate()
