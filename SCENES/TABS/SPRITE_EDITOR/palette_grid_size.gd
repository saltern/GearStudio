extends TextureRect

const COLUMNS: int = 16
const TILE_SIZE: int = 17

@export var by_channel: CheckButton
@export var selection_mgr: PaletteSelection
@export var picker: ColorPicker

@onready var editor: SpriteEditor = owner


func _ready() -> void:
	editor.preview_outdated.connect(update)
	by_channel.toggled.connect(on_by_channel_toggled)
	update()


func update() -> void:
	var rows: int = editor.this_sprite.get_color_count() / COLUMNS
	custom_minimum_size.y = TILE_SIZE * rows + 1


func on_by_channel_toggled(toggled_on: bool) -> void:
	if toggled_on:
		picker.color_mode = ColorPicker.MODE_RGB
		picker.color_modes_visible = false
	else:
		picker.color_modes_visible = true


#func on_color_changed(color: Color) -> void:
	#var undo_redo: UndoRedo = editor.undo_redo
	#
	#var old_palette: PackedByteArray = editor.this_sprite.palette.duplicate()
	#var new_palette: PackedByteArray = old_palette.duplicate()
		#
	#for index: int in editor.this_sprite.get_color_count():
		#if !selection_mgr.selected[index]:
			#continue
		#
		#new_palette[4 * index + 0] = color.r8
		#new_palette[4 * index + 1] = color.g8
		#new_palette[4 * index + 2] = color.b8
		#new_palette[4 * index + 3] = color.a8
#
	#undo_redo.create_action()
