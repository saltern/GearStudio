extends CheckButton

@export var dialog: SpriteImportDialog


func _ready() -> void:
	dialog.placement_method_set.connect(on_placement_method_set)


func _toggled(toggled_on: bool) -> void:
	dialog.set_placement_by_filename(toggled_on)


func on_placement_method_set(method: SpriteImportDialog.PlacementMethod) -> void:
	match method:
		SpriteImportDialog.PlacementMethod.REPLACE:
			show()
		_:
			hide()
			button_pressed = false
