extends PopupMenu

enum Items {
	IMPORT,
	EXPORT,
	DELETE,
}

@onready var editor: SpriteEditor = owner


func _ready() -> void:
	index_pressed.connect(on_index_pressed)


func on_index_pressed(index: int) -> void:
	match index:
		Items.IMPORT:
			GlobalSignals.sprite_importer_open(
				editor.session, editor.sprite_block
			)
