extends FoldableContainer

@export var dialog: SpriteImportDialog


func _ready() -> void:
	dialog.session_set.connect(check_visibility.unbind(2))


func check_visibility() -> void:
	visible = !dialog.has_palettes()
