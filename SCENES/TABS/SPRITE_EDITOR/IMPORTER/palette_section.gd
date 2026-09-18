extends FoldableContainer

@export var dialog: SpriteImportDialog


func _ready() -> void:
	dialog.session_set.connect(check_visibility.unbind(1))


func check_visibility(session: Session) -> void:
	visible = !session.has_palettes()
